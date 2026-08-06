import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// One-time setup utility: uploads Kipack's logo into a public Storage
// bucket so send-auth-email can reference it as a normal HTTPS URL. Base64
// data URIs (the original approach) are stripped or refused outright by
// many email clients (Gmail, Outlook, and most corporate mail filters
// treat inline images as a spam/phishing signal) — a hosted URL is the
// only approach that reliably works across clients.
//
// Safe to re-run: creates the bucket only if missing, and upserts the file
// each time, so calling this again just re-uploads the same fixed logo.
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const BUCKET = "brand-assets";
const OBJECT_PATH = "kipack-logo.png";

const LOGO_BASE64 =
  "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";

function base64ToBytes(input: string): Uint8Array {
  return Uint8Array.from(atob(input), (c) => c.charCodeAt(0));
}

Deno.serve(async () => {
  try {
    // Create the bucket if it doesn't exist yet (ignore "already exists").
    await fetch(`${SUPABASE_URL}/storage/v1/bucket`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
        apikey: SERVICE_ROLE_KEY,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ id: BUCKET, name: BUCKET, public: true }),
    });

    const uploadRes = await fetch(
      `${SUPABASE_URL}/storage/v1/object/${BUCKET}/${OBJECT_PATH}`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
          apikey: SERVICE_ROLE_KEY,
          "Content-Type": "image/png",
          "x-upsert": "true",
        },
        body: base64ToBytes(LOGO_BASE64),
      },
    );

    if (!uploadRes.ok) {
      const err = await uploadRes.text();
      return new Response(JSON.stringify({ error: err }), { status: 502 });
    }

    const publicUrl = `${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/${OBJECT_PATH}`;
    return new Response(JSON.stringify({ ok: true, publicUrl }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), { status: 500 });
  }
});
