import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// Implements Supabase Auth's "Send Email" hook so every auth email
// (signup confirmation, password recovery, email change, ...) is sent as a
// branded Kipack email via Resend instead of Supabase's generic default.
//
// verify_jwt is off because Supabase Auth calls this directly (not a
// logged-in user), and it isn't a JWT-bearing call — instead, Supabase
// signs the request per the Standard Webhooks spec using the secret shown
// when the hook is enabled (Authentication > Hooks in the dashboard), and
// this verifies that signature by hand below so the endpoint can't be
// spoofed into emailing arbitrary "reset your password" links to anyone.
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const HOOK_SECRET = Deno.env.get("SEND_EMAIL_HOOK_SECRET"); // as shown in the dashboard, e.g. "v1,whsec_XXXX"
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "https://xvbtracxtlwpideblnvm.supabase.co";
const FROM = "Kipack <kipack@fooserd.com>";

function base64ToBytes(input: string): Uint8Array {
  return Uint8Array.from(atob(input), (c) => c.charCodeAt(0));
}

function bytesToBase64(bytes: ArrayBuffer): string {
  return btoa(String.fromCharCode(...new Uint8Array(bytes)));
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

async function verifySignature(payload: string, headers: Headers): Promise<boolean> {
  if (!HOOK_SECRET) return false;
  const id = headers.get("webhook-id");
  const timestamp = headers.get("webhook-timestamp");
  const signatureHeader = headers.get("webhook-signature");
  if (!id || !timestamp || !signatureHeader) return false;

  // The dashboard shows this as "v1,whsec_XXXX" — accept that whole string
  // verbatim (most likely what gets pasted) or just the "whsec_XXXX" part.
  const rawSecret = HOOK_SECRET.includes(",") ? HOOK_SECRET.split(",").pop()! : HOOK_SECRET;
  const secretBytes = base64ToBytes(rawSecret.replace(/^whsec_/, ""));
  const key = await crypto.subtle.importKey(
    "raw",
    secretBytes,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signedContent = `${id}.${timestamp}.${payload}`;
  const signatureBytes = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(signedContent));
  const expected = bytesToBase64(signatureBytes);

  return signatureHeader
    .split(" ")
    .map((entry) => entry.split(",")[1])
    .filter(Boolean)
    .some((sig) => timingSafeEqual(sig, expected));
}

function escapeHtml(value: string): string {
  return value.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function buildVerifyLink(tokenHash: string, type: string, redirectTo: string): string {
  const url = new URL(`${SUPABASE_URL}/auth/v1/verify`);
  url.searchParams.set("token", tokenHash);
  url.searchParams.set("type", type);
  url.searchParams.set("redirect_to", redirectTo);
  return url.toString();
}

function wrapEmail(title: string, bodyHtml: string): string {
  return `
    <div style="font-family: -apple-system, Segoe UI, Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px 24px; background: #ECF2E8;">
      <div style="background: #132A1D; color: #C6E83E; font-weight: 800; font-size: 20px; padding: 16px 24px; border-radius: 16px 16px 0 0;">Kipack</div>
      <div style="background: #FFFFFF; padding: 28px 24px; border-radius: 0 0 16px 16px;">
        <h1 style="font-size: 20px; color: #16241C; margin: 0 0 12px;">${title}</h1>
        ${bodyHtml}
      </div>
    </div>
  `;
}

function buttonHtml(href: string, label: string): string {
  return `<a href="${href}" style="display: inline-block; margin-top: 16px; padding: 14px 24px; background: #C6E83E; color: #132A1D; font-weight: 700; text-decoration: none; border-radius: 12px;">${label}</a>`;
}

function codeHtml(code: string): string {
  return `<p style="font-size: 32px; font-weight: 800; letter-spacing: 6px; color: #132A1D; text-align: center; margin: 20px 0;">${escapeHtml(code)}</p>`;
}

function templateFor(actionType: string, link: string, code: string): { subject: string; html: string } {
  switch (actionType) {
    case "signup":
      return {
        subject: "Confirma tu cuenta de Kipack",
        html: wrapEmail(
          "Confirma tu cuenta",
          `<p style="color:#6B7A70;">Pulsa el botón para activar tu cuenta de Kipack.</p>${buttonHtml(link, "Confirmar cuenta")}`,
        ),
      };
    case "recovery":
      // Code-based, not link-based: the app's "forgot password" flow has the
      // user type this in directly (same pattern as account deletion) —
      // see AuthService.verifyPasswordResetCode. No deep link involved, so
      // there's nothing here for a custom URL scheme to hijack.
      return {
        subject: "Restablece tu contraseña de Kipack",
        html: wrapEmail(
          "Restablece tu contraseña",
          `<p style="color:#6B7A70;">Alguien (probablemente tú) pidió cambiar la contraseña de tu cuenta de Kipack. Introduce este código en la app para continuar:</p>` +
            codeHtml(code) +
            `<p style="color:#6B7A70; font-size: 13px;">Caduca en 1 hora. Si no fuiste tú, ignora este correo.</p>`,
        ),
      };
    case "email_change":
      return {
        subject: "Confirma tu nuevo correo en Kipack",
        html: wrapEmail(
          "Confirma tu nuevo correo",
          `<p style="color:#6B7A70;">Confirma que quieres usar este correo con tu cuenta de Kipack.</p>${buttonHtml(link, "Confirmar correo")}`,
        ),
      };
    default:
      return {
        subject: "Kipack",
        html: wrapEmail(
          "Verifica tu cuenta",
          `<p style="color:#6B7A70;">Pulsa el botón para continuar.</p>${buttonHtml(link, "Continuar")}`,
        ),
      };
  }
}

Deno.serve(async (req: Request) => {
  const payload = await req.text();

  if (!(await verifySignature(payload, req.headers))) {
    return new Response("Invalid signature", { status: 401 });
  }
  if (!RESEND_API_KEY) {
    console.error("RESEND_API_KEY is not set");
    return new Response("Server misconfigured", { status: 500 });
  }

  try {
    const { user, email_data } = JSON.parse(payload);
    const actionType = String(email_data?.email_action_type ?? "");
    const tokenHash = String(email_data?.token_hash ?? "");
    const token = String(email_data?.token ?? "");
    const redirectTo = String(email_data?.redirect_to ?? "");
    const toEmail = String(user?.email ?? "");

    if (!toEmail || !tokenHash) {
      return new Response(JSON.stringify({ error: "Missing user email or token" }), { status: 400 });
    }
    if (actionType === "recovery" && !token) {
      return new Response(JSON.stringify({ error: "Missing OTP token for recovery email" }), { status: 400 });
    }

    const link = buildVerifyLink(tokenHash, actionType, redirectTo);
    const { subject, html } = templateFor(actionType, link, token);

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM,
        to: [escapeHtml(toEmail)],
        subject,
        html,
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      console.error("Resend error:", err);
      return new Response(JSON.stringify({ error: err }), { status: 502 });
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: String(error) }), { status: 500 });
  }
});
