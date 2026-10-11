/**
 * Kipack AI proxy. Holds the OpenRouter key so it never ships inside the
 * app, and only accepts structured trip data — the prompts are built here,
 * so this endpoint can't be used as a general-purpose free LLM.
 *
 *   POST /v1/generate  -> { items: Item[] }
 *   POST /v1/refine    -> { reply: string, items: Item[] }
 */

interface Env {
  OPENROUTER_API_KEY: string;
  APP_TOKEN: string;
  MODEL: string;
  AI_LIMITER: RateLimit;
}

type Category = "clothing" | "toiletries" | "electronics" | "documents" | "misc";
const CATEGORIES: Category[] = ["clothing", "toiletries", "electronics", "documents", "misc"];

interface Item {
  name: string;
  category: Category;
  quantity: number;
}

interface Weather {
  season: string;
  minC: number | null;
  maxC: number | null;
  rainPct: number | null;
}

interface GenerateRequest {
  language: string;
  destination: string;
  startDate: string;
  endDate: string;
  durationDays: number;
  types: string[];
  activities: string[];
  peopleCount: number;
  weather: Weather | null;
}

interface RefineRequest {
  language: string;
  destination: string;
  durationDays: number;
  peopleCount: number;
  items: Item[];
  instruction: string;
}

class BadRequest extends Error {}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (request.method !== "POST") return json({ error: "not_found" }, 404);
    if (request.headers.get("X-Kipack-Token") !== env.APP_TOKEN) {
      return json({ error: "unauthorized" }, 401);
    }

    const ip = request.headers.get("CF-Connecting-IP") ?? "unknown";
    const { success } = await env.AI_LIMITER.limit({ key: ip });
    if (!success) return json({ error: "rate_limited" }, 429);

    try {
      const body = await request.json().catch(() => {
        throw new BadRequest("invalid json");
      });
      if (url.pathname === "/v1/generate") {
        const req = parseGenerate(body);
        const content = await callModel(env, systemPrompt(req.language), userPrompt(req));
        return json({ items: parseItemsArray(content) });
      }
      if (url.pathname === "/v1/refine") {
        const req = parseRefine(body);
        const content = await callModel(env, refineSystemPrompt(req.language), refineUserPrompt(req));
        return json(parseRefineResult(content));
      }
      return json({ error: "not_found" }, 404);
    } catch (error) {
      if (error instanceof BadRequest) return json({ error: error.message }, 400);
      console.error(error);
      return json({ error: "upstream_failed" }, 502);
    }
  },
} satisfies ExportedHandler<Env>;

// ---------------------------------------------------------------- validation

function str(value: unknown, max: number, field: string): string {
  if (typeof value !== "string") throw new BadRequest(`${field} must be a string`);
  const trimmed = value.trim();
  if (!trimmed || trimmed.length > max) throw new BadRequest(`${field} invalid length`);
  return trimmed;
}

function int(value: unknown, min: number, max: number, field: string): number {
  if (typeof value !== "number" || !Number.isFinite(value)) throw new BadRequest(`${field} must be a number`);
  const n = Math.round(value);
  if (n < min || n > max) throw new BadRequest(`${field} out of range`);
  return n;
}

function optNum(value: unknown, min: number, max: number): number | null {
  if (typeof value !== "number" || !Number.isFinite(value)) return null;
  return Math.min(max, Math.max(min, value));
}

function strList(value: unknown, maxItems: number, field: string): string[] {
  if (value == null) return [];
  if (!Array.isArray(value) || value.length > maxItems) throw new BadRequest(`${field} invalid`);
  return value.map((v, i) => str(v, 40, `${field}[${i}]`));
}

function language(value: unknown): string {
  return value === "en" || value === "fr" ? value : "es";
}

function date(value: unknown, field: string): string {
  const s = str(value, 10, field);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(s)) throw new BadRequest(`${field} invalid`);
  return s;
}

function parseGenerate(body: any): GenerateRequest {
  const w = body?.weather;
  return {
    language: language(body?.language),
    destination: str(body?.destination, 120, "destination"),
    startDate: date(body?.startDate, "startDate"),
    endDate: date(body?.endDate, "endDate"),
    durationDays: int(body?.durationDays, 1, 120, "durationDays"),
    types: strList(body?.types, 10, "types"),
    activities: strList(body?.activities, 15, "activities"),
    peopleCount: int(body?.peopleCount, 1, 30, "peopleCount"),
    weather:
      w && typeof w === "object"
        ? {
            season: str(w.season, 20, "weather.season"),
            minC: optNum(w.minC, -60, 60),
            maxC: optNum(w.maxC, -60, 60),
            rainPct: optNum(w.rainPct, 0, 100),
          }
        : null,
  };
}

function parseRefine(body: any): RefineRequest {
  if (!Array.isArray(body?.items) || body.items.length > 120) throw new BadRequest("items invalid");
  return {
    language: language(body?.language),
    destination: str(body?.destination, 120, "destination"),
    durationDays: int(body?.durationDays, 1, 120, "durationDays"),
    peopleCount: int(body?.peopleCount, 1, 30, "peopleCount"),
    items: body.items.map((it: any, i: number) => ({
      name: str(it?.name, 80, `items[${i}].name`),
      category: CATEGORIES.includes(it?.category) ? it.category : "misc",
      quantity: int(it?.quantity ?? 1, 1, 999, `items[${i}].quantity`),
    })),
    instruction: str(body?.instruction, 500, "instruction"),
  };
}

// ---------------------------------------------------------------- OpenRouter

async function callModel(env: Env, system: string, user: string): Promise<string> {
  const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${env.OPENROUTER_API_KEY}`,
      "Content-Type": "application/json",
      "X-Title": "Kipack",
    },
    body: JSON.stringify({
      model: env.MODEL,
      temperature: 0.4,
      max_tokens: 4000,
      // Only the final JSON is needed, not chain-of-thought — cuts response
      // time a lot on reasoning models; ignored by models without it.
      reasoning: { enabled: false },
      messages: [
        { role: "system", content: system },
        { role: "user", content: user },
      ],
    }),
  });
  if (!response.ok) {
    throw new Error(`OpenRouter ${response.status}: ${await response.text()}`);
  }
  const data: any = await response.json();
  const content = data?.choices?.[0]?.message?.content;
  if (typeof content !== "string") throw new Error("OpenRouter returned no content");
  return content;
}

// ---------------------------------------------------------------- prompts

function languageName(lang: string): string {
  return lang === "en" ? "inglés" : lang === "fr" ? "francés" : "español";
}

/**
 * Left unconstrained, the model defaults to Latin-American vocabulary
 * (poncho, valija, computadora...); Kipack's Spanish users are in Spain.
 */
function spanishVocabNote(lang: string): string {
  if (lang !== "es") return "";
  return (
    ' Usa siempre español de España (castellano peninsular), nunca ' +
    'palabras propias del español latinoamericano: di "chubasquero" o ' +
    '"impermeable" (nunca "poncho"), "maleta" (nunca "valija"), ' +
    '"ordenador" (nunca "computadora"), "gafas de sol" (nunca "lentes de ' +
    'sol"), "chaqueta" o "cazadora" (nunca "campera"), "calcetines" ' +
    '(nunca "medias"), "manta" (nunca "cobija" ni "frazada"), "bañador" ' +
    '(nunca "traje de baño"), "zapatillas" (nunca "tenis").'
  );
}

function systemPrompt(lang: string): string {
  const ln = languageName(lang);
  return (
    "Eres un asistente experto en preparar equipaje de viaje, y optimizas la lista para que sea " +
    "práctica: solo incluyes lo que de verdad hace falta para ESE viaje concreto, no una lista " +
    'genérica de "cosas que se suelen llevar". Cada artículo debe estar justificado por los datos ' +
    "del viaje (destino, duración, tipo de viaje, clima). En particular, respeta estrictamente la " +
    "probabilidad de lluvia indicada: si es inferior al 40%, NO incluyas paraguas, impermeable ni " +
    "ropa de lluvia; solo inclúyelos si es 40% o más, o si el clima no está disponible. Igual de " +
    "estricto con el frío/calor: no dupliques prendas de abrigo si las " +
    "temperaturas son suaves, ni añadas ropa de abrigo pesada si hace calor. " +
    "Si se indican actividades específicas (buceo, esquí, senderismo, surf, ciclismo, camping, " +
    "fotografía, running, etc.), incluye el equipo técnico específico que esa actividad realmente " +
    "necesita (p. ej. esquí pide guantes térmicos y gafas de nieve, buceo pide gafas/tubo o neopreno) " +
    "en vez de conformarte con ropa genérica del tipo de viaje. " +
    'El destino se indica siempre como "lugar, país" — usa EXACTAMENTE ese país, nunca asumas un país ' +
    "distinto aunque el nombre del lugar se parezca al de otro sitio más conocido (por ejemplo, un " +
    'destino llamado "Singa" en Perú no tiene nada que ver con Singapur: no incluyas trámites, visados ' +
    "ni nada específico de un país que no sea el indicado explícitamente). " +
    "Respondes ÚNICAMENTE con un array JSON válido, sin texto adicional, sin markdown, sin backticks. " +
    "Cada elemento del array es un objeto con exactamente estas claves: " +
    `"name" (string, nombre del artículo escrito en ${ln} — TODOS los nombres deben estar ` +
    `en ${ln}, sin excepción, aunque el destino o el tipo de viaje estén en otro idioma), ` +
    '"category" (uno de: "clothing", "toiletries", "electronics", "documents", "misc"), ' +
    '"quantity" (entero positivo, cantidad total a llevar contando a todas las personas del viaje).' +
    spanishVocabNote(lang)
  );
}

function userPrompt(req: GenerateRequest): string {
  const w = req.weather;
  const weatherLine =
    w == null
      ? "Clima: no disponible."
      : w.minC != null && w.maxC != null && w.rainPct != null
        ? `Clima: estación ${w.season}, temperaturas entre ${Math.round(w.minC)}°C y ` +
          `${Math.round(w.maxC)}°C, probabilidad de lluvia ${Math.round(w.rainPct)}%.`
        : `Clima: estación ${w.season} (previsión detallada no disponible aún, el viaje es a más de 5 días vista).`;
  const activitiesLine = req.activities.length
    ? `\n- Actividades específicas: ${req.activities.join(", ")}`
    : "";
  const ln = languageName(req.language);
  return `Genera la lista de equipaje para este viaje:
- Destino: ${req.destination}
- Duración: ${req.durationDays} días (${req.startDate} a ${req.endDate})
- Tipo(s) de viaje: ${req.types.join(", ")}
- Número de personas: ${req.peopleCount}
- ${weatherLine}${activitiesLine}

Incluye documentación, electrónica, higiene, ropa (ajustada a los días de viaje y al clima) y cualquier artículo específico de los tipos de viaje y actividades indicados. Ajusta las cantidades al número de personas cuando el artículo sea personal (ej. cepillo de dientes, cargador). No incluyas artículos de lluvia si la probabilidad de lluvia indicada es baja. No incluyas más de 35 artículos, y no metas artículos "por si acaso" que no encajen con los datos anteriores — menos es mejor si es lo correcto para este viaje. Escribe el "name" de cada artículo en ${ln}. Responde solo con el array JSON.
`;
}

function refineSystemPrompt(lang: string): string {
  const ln = languageName(lang);
  return (
    "Eres un asistente que ajusta una lista de equipaje de viaje ya existente según lo que pida el " +
    "usuario en lenguaje natural (por ejemplo: reducir volumen o número de artículos, quitar algo, " +
    "añadir algo, adaptar la lista a una actividad concreta). Si la petición no tiene nada que ver " +
    "con el equipaje o el viaje, no la cumplas: devuelve la lista sin cambios y explícalo en reply. " +
    "Devuelve ÚNICAMENTE un objeto JSON con exactamente estas dos claves: " +
    `"reply" (string en ${ln}: una frase corta y concreta explicando qué has cambiado y por qué), ` +
    '"items" (el array COMPLETO de artículos ya actualizado — no solo los cambios — con el mismo ' +
    `formato de siempre: objetos con "name" (en ${ln}, TODOS los artículos, no solo los nuevos), ` +
    '"category" (clothing/toiletries/electronics/documents/misc) ' +
    'y "quantity"). Nunca dejes "items" vacío salvo que el usuario pida explícitamente vaciar la lista. ' +
    "Sin texto adicional, sin markdown, sin backticks." +
    spanishVocabNote(lang)
  );
}

function refineUserPrompt(req: RefineRequest): string {
  const itemsList = req.items
    .map((i) => `- ${i.name} (${i.category}, cantidad ${i.quantity})`)
    .join("\n");
  return `Viaje: ${req.destination}, ${req.durationDays} días, ${req.peopleCount} persona(s).
Lista actual:
${itemsList}

Petición del usuario: "${req.instruction}"

Aplica el cambio pedido y responde con el objeto JSON descrito (reply + items), todo en ${languageName(req.language)}.
`;
}

// ---------------------------------------------------------------- parsing

function cleanItems(raw: unknown): Item[] {
  if (!Array.isArray(raw)) return [];
  const items: Item[] = [];
  for (const entry of raw.slice(0, 150)) {
    const name = typeof entry?.name === "string" ? entry.name.trim().slice(0, 80) : "";
    if (!name) continue;
    const category: Category = CATEGORIES.includes(entry?.category) ? entry.category : "misc";
    const q = typeof entry?.quantity === "number" ? Math.round(entry.quantity) : 1;
    items.push({ name, category, quantity: Math.min(999, Math.max(1, q)) });
  }
  return items;
}

function parseItemsArray(content: string): Item[] {
  const start = content.indexOf("[");
  const end = content.lastIndexOf("]");
  if (start === -1 || end < start) throw new Error("model returned no JSON array");
  const items = cleanItems(JSON.parse(content.slice(start, end + 1)));
  if (!items.length) throw new Error("model returned no valid items");
  return items;
}

function parseRefineResult(content: string): { reply: string; items: Item[] } {
  const start = content.indexOf("{");
  const end = content.lastIndexOf("}");
  if (start === -1 || end < start) throw new Error("model returned no JSON object");
  const map = JSON.parse(content.slice(start, end + 1));
  const reply = typeof map?.reply === "string" ? map.reply.trim().slice(0, 600) : "";
  const items = cleanItems(map?.items);
  if (!reply || !items.length) throw new Error("model returned incomplete result");
  return { reply, items };
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
}
