// Verifies a Google Play subscription purchase token server-side and, if
// valid, marks the calling user premium in `profiles`. Never trust a
// client-reported "purchased" event alone — this is the thing that
// actually grants Premium.
//
// Deploy: `supabase functions deploy verify-play-purchase` (or via the
// dashboard's Edge Functions UI — paste this file's contents).
//
// Required secrets (Project Settings -> Edge Functions -> Secrets, or
// `supabase secrets set`):
//   GOOGLE_SERVICE_ACCOUNT_EMAIL  - the service account's `client_email`
//   GOOGLE_SERVICE_ACCOUNT_KEY    - the service account's `private_key`
//                                   (the full PEM block, including the
//                                   BEGIN/END lines)
// SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY are provided
// automatically by the platform — nothing to set for those.
//
// The service account needs "Financial data" access to this app, granted
// via Play Console -> Setup -> API access.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

const PACKAGE_NAME = 'com.fooserd.kipack';

Deno.serve(async (req: Request) => {
  try {
    if (req.method !== 'POST') {
      return jsonResponse({ error: 'Method not allowed' }, 405);
    }

    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return jsonResponse({ error: 'No autorizado' }, 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    // Identify the caller from their own session — RLS still applies to
    // this client, it's only used to find out *who* is asking.
    const callerClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const {
      data: { user },
      error: userError,
    } = await callerClient.auth.getUser();
    if (userError || !user) {
      return jsonResponse({ error: 'No autorizado' }, 401);
    }

    let body: { purchaseToken?: string };
    try {
      body = await req.json();
    } catch {
      return jsonResponse({ error: 'Cuerpo de la petición inválido' }, 400);
    }
    const purchaseToken = body.purchaseToken;
    if (!purchaseToken || typeof purchaseToken !== 'string') {
      return jsonResponse({ error: 'Falta purchaseToken' }, 400);
    }

    const serviceAccountEmail = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_EMAIL');
    const privateKeyPem = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_KEY');
    if (!serviceAccountEmail || !privateKeyPem) {
      console.error('Missing GOOGLE_SERVICE_ACCOUNT_EMAIL/KEY secrets');
      return jsonResponse({ error: 'Error de configuración del servidor' }, 500);
    }

    const accessToken = await getGoogleAccessToken(serviceAccountEmail, privateKeyPem);

    const verifyUrl =
      `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
      `${PACKAGE_NAME}/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`;
    const verifyResponse = await fetch(verifyUrl, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    if (!verifyResponse.ok) {
      console.error('Google verify failed:', verifyResponse.status, await verifyResponse.text());
      return jsonResponse({ error: 'No se pudo verificar la compra con Google Play' }, 400);
    }

    // VERIFY AT IMPLEMENTATION TIME: this matches the documented
    // subscriptionsv2.get response shape as of when this was written —
    // https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2
    // Double-check `subscriptionState` and the `lineItems[]` shape
    // (expiryTime / productId / offerDetails.basePlanId) haven't shifted
    // before relying on this in production.
    const subscription = await verifyResponse.json();
    const state: string | undefined = subscription.subscriptionState;
    const lineItem = subscription.lineItems?.[0];
    const expiryTime: string | undefined = lineItem?.expiryTime;
    const productId: string | undefined = lineItem?.productId;
    const basePlanId: string | undefined =
      lineItem?.offerDetails?.basePlanId ?? lineItem?.autoRenewingPlan?.basePlanId;

    const isActive =
      state === 'SUBSCRIPTION_STATE_ACTIVE' || state === 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD';

    if (!isActive || !expiryTime) {
      return jsonResponse({ error: 'La suscripción no está activa' }, 400);
    }

    // Anti-fraud: if the client set an obfuscated account id when starting
    // the purchase (see BillingService.buy), Google echoes it back here —
    // cross-check it matches the caller. Purchases made before this field
    // existed won't have one, so this only rejects when it's present AND
    // wrong, never just because it's missing.
    const externalAccountId: string | undefined =
      subscription.externalAccountIdentifiers?.obfuscatedExternalAccountId;
    if (externalAccountId && externalAccountId !== user.id) {
      return jsonResponse(
        { error: 'Esta compra pertenece a otra cuenta' },
        403,
      );
    }

    // Service-role client so this write bypasses `protect_premium_columns`
    // (see supabase/sql/premium_subscriptions.sql) — that trigger exists
    // specifically to stop everyone EXCEPT this function from setting these
    // columns.
    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { error: updateError } = await adminClient
      .from('profiles')
      .update({
        premium_active: true,
        premium_expires_at: expiryTime,
        premium_product_id: productId ?? null,
        premium_purchase_token: purchaseToken,
      })
      .eq('id', user.id);

    if (updateError) {
      // Unique violation on premium_purchase_token (see
      // supabase/sql/premium_purchase_token_unique.sql) means this exact
      // token is already linked to a DIFFERENT account — never trust a
      // client-reported "purchased" event enough to let it re-claim
      // someone else's subscription onto a new account.
      if (updateError.code === '23505') {
        return jsonResponse(
          { error: 'Esta compra ya está vinculada a otra cuenta' },
          409,
        );
      }
      console.error('profiles update failed:', updateError);
      return jsonResponse({ error: 'No se pudo guardar la suscripción' }, 500);
    }

    return jsonResponse({ ok: true, expiresAt: expiryTime, basePlanId }, 200);
  } catch (error) {
    console.error('verify-play-purchase error:', error);
    return jsonResponse({ error: 'Error interno' }, 500);
  }
});

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

/// Mints a short-lived Google OAuth2 access token via the service-account
/// JWT-bearer flow, using only Deno's built-in Web Crypto (no npm/Google
/// SDK dependency, since those don't reliably run in the Edge Function
/// runtime).
async function getGoogleAccessToken(
  serviceAccountEmail: string,
  privateKeyPem: string,
): Promise<string> {
  const header = { alg: 'RS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  const claims = {
    iss: serviceAccountEmail,
    scope: 'https://www.googleapis.com/auth/androidpublisher',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };

  const encoder = new TextEncoder();
  const headerB64 = base64UrlEncode(encoder.encode(JSON.stringify(header)));
  const claimsB64 = base64UrlEncode(encoder.encode(JSON.stringify(claims)));
  const signingInput = `${headerB64}.${claimsB64}`;

  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToDer(privateKeyPem),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    encoder.encode(signingInput),
  );
  const jwt = `${signingInput}.${base64UrlEncode(new Uint8Array(signature))}`;

  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  if (!tokenResponse.ok) {
    throw new Error(`Google OAuth token exchange failed: ${await tokenResponse.text()}`);
  }
  const tokenJson = await tokenResponse.json();
  return tokenJson.access_token as string;
}

function base64UrlEncode(data: Uint8Array): string {
  let binary = '';
  for (const byte of data) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

/// Strips the PEM header/footer/whitespace and base64-decodes the rest into
/// raw DER bytes, as required by `crypto.subtle.importKey('pkcs8', ...)`.
function pemToDer(pem: string): Uint8Array {
  const b64 = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s+/g, '');
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}
