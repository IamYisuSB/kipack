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

// Kipack pin+wordmark logo, inlined as a data URI so the email is fully
// self-contained (no external image host / broken-image-icon risk in
// clients that block remote images by default).
const LOGO_BASE64 =
  "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";

function wrapEmail(title: string, bodyHtml: string): string {
  return `
    <div style="font-family: -apple-system, Segoe UI, Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px 24px; background: #ECF2E8;">
      <div style="background: #132A1D; padding: 20px 24px; border-radius: 16px 16px 0 0; text-align: center;">
        <img src="data:image/png;base64,${LOGO_BASE64}" alt="Kipack" width="130" style="display: block; margin: 0 auto; height: auto; border: 0;" />
      </div>
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
