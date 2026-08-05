import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../core/data/country_catalog.dart';
import '../../trips/models/trip.dart';
import '../models/packing_category.dart';
import '../models/packing_item.dart';

/// Generates a packing list by asking an LLM (via OpenRouter, an
/// OpenAI-compatible gateway to many model providers) to produce one
/// tailored to the trip — destination, duration, trip type(s), people count
/// and, when available, real weather (season/temps/rain).
///
/// Throws on any failure (missing key, network, bad response) so the
/// caller can fall back to [PackingListGenerator] — this class never
/// silently returns an empty/partial list.
class AiPackingListService {
  const AiPackingListService();

  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _uuid = Uuid();

  String? get _apiKey {
    final key = dotenv.maybeGet('OPENROUTER_API_KEY');
    return (key == null || key.isEmpty) ? null : key;
  }

  String get _model =>
      dotenv.maybeGet('OPENROUTER_MODEL')?.trim().isNotEmpty == true
      ? dotenv.get('OPENROUTER_MODEL')
      : 'deepseek/deepseek-v4-flash-0731';

  bool get isConfigured => _apiKey != null;

  /// Human-readable name (in Spanish, since it's only used inside prompts
  /// sent to the model, never shown to the user) for an app language code —
  /// this is what tells the model what language to write item names in,
  /// independent of the (always-Spanish) prompt instructions themselves.
  String _languageName(String language) => switch (language) {
    'en' => 'inglés',
    'fr' => 'francés',
    _ => 'español',
  };

  /// Extra guardrail for Spanish output only — left unconstrained, the model
  /// defaults to a generic/Latin-American lexicon (poncho, campera, valija,
  /// computadora...) since that vocabulary dominates its Spanish training
  /// data; Kipack's Spanish-language users are in Spain, so this steers word
  /// choice toward Peninsular Spanish (castellano) terms with concrete
  /// examples, since a vague "use Spanish from Spain" instruction alone is
  /// easy for the model to ignore.
  String _spanishVocabNote(String language) {
    if (language != 'es') return '';
    return ' Usa siempre español de España (castellano peninsular), nunca '
        'palabras propias del español latinoamericano: di "chubasquero" o '
        '"impermeable" (nunca "poncho"), "maleta" (nunca "valija"), '
        '"ordenador" (nunca "computadora"), "gafas de sol" (nunca "lentes de '
        'sol"), "chaqueta" o "cazadora" (nunca "campera"), "calcetines" '
        '(nunca "medias"), "manta" (nunca "cobija" ni "frazada"), "bañador" '
        '(nunca "traje de baño"), "zapatillas" (nunca "tenis").';
  }

  /// "Singa" alone is genuinely ambiguous — it's also a real, small place in
  /// Huánuco, Perú, and a model given just that bare name (no country) will
  /// happily "correct" it to the much more famous Singapur it has strong
  /// training associations with, hallucinating visa advice and the like for
  /// the wrong country entirely. `trip.destination` only ever stores the
  /// bare place name (see `NewTripScreen._submit`), so this appends the
  /// country — already captured on the trip via geocoding — whenever it's
  /// available, to close that gap.
  String _destinationLine(Trip trip) {
    final countryCode = trip.countryCode;
    if (countryCode == null) return trip.destination;
    return '${trip.destination}, ${countryDisplayName(countryCode)}';
  }

  Future<List<PackingItem>> generate(
    Trip trip, {
    String language = 'es',
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null) {
      throw StateError('OPENROUTER_API_KEY no configurada');
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-Title': 'Kipack',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.4,
        // We only need the final JSON, not the model's chain-of-thought —
        // for reasoning models (e.g. DeepSeek V4 Flash) this alone cuts
        // response time by ~6x (measured: 60s -> 10s for a real packing
        // list). Ignored harmlessly by models that don't support it.
        'reasoning': {'enabled': false},
        'messages': [
          {'role': 'system', 'content': _systemPrompt(language)},
          {'role': 'user', 'content': _userPrompt(trip, language)},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException(
        'OpenRouter respondió ${response.statusCode}: ${response.body}',
      );
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content =
        (body['choices'] as List<dynamic>).first['message']['content']
            as String;
    return _parseItems(content);
  }

  String _systemPrompt(String language) {
    final languageName = _languageName(language);
    return 'Eres un asistente experto en preparar equipaje de viaje, y optimizas la lista para que sea '
        'práctica: solo incluyes lo que de verdad hace falta para ESE viaje concreto, no una lista '
        'genérica de "cosas que se suelen llevar". Cada artículo debe estar justificado por los datos '
        'del viaje (destino, duración, tipo de viaje, clima). En particular, respeta estrictamente la '
        'probabilidad de lluvia indicada: si es inferior al 40%, NO incluyas paraguas, impermeable ni '
        'ropa de lluvia; solo inclúyelos si es 40% o más, o si el clima no está disponible. Igual de '
        'estricto con el frío/calor: no dupliques prendas de abrigo si las '
        'temperaturas son suaves, ni añadas ropa de abrigo pesada si hace calor. '
        'Si se indican actividades específicas (buceo, esquí, senderismo, surf, ciclismo, camping, '
        'fotografía, running, etc.), incluye el equipo técnico específico que esa actividad realmente '
        'necesita (p. ej. esquí pide guantes térmicos y gafas de nieve, buceo pide gafas/tubo o neopreno) '
        'en vez de conformarte con ropa genérica del tipo de viaje. '
        'El destino se indica siempre como "lugar, país" — usa EXACTAMENTE ese país, nunca asumas un país '
        'distinto aunque el nombre del lugar se parezca al de otro sitio más conocido (por ejemplo, un '
        'destino llamado "Singa" en Perú no tiene nada que ver con Singapur: no incluyas trámites, visados '
        'ni nada específico de un país que no sea el indicado explícitamente). '
        'Respondes ÚNICAMENTE con un array JSON válido, sin texto adicional, sin markdown, sin backticks. '
        'Cada elemento del array es un objeto con exactamente estas claves: '
        '"name" (string, nombre del artículo escrito en $languageName — TODOS los nombres deben estar '
        'en $languageName, sin excepción, aunque el destino o el tipo de viaje estén en otro idioma), '
        '"category" (uno de: "clothing", "toiletries", "electronics", "documents", "misc"), '
        '"quantity" (entero positivo, cantidad total a llevar contando a todas las personas del viaje).'
        '${_spanishVocabNote(language)}';
  }

  String _userPrompt(Trip trip, String language) {
    final types = trip.types.map((t) => t.label).join(', ');
    final weather = trip.weather;
    final weatherLine = weather == null
        ? 'Clima: no disponible.'
        : weather.hasForecast
        ? 'Clima: estación ${weather.season}, temperaturas entre ${weather.avgMinTempC!.round()}°C y '
              '${weather.avgMaxTempC!.round()}°C, probabilidad de lluvia ${(weather.rainProbability! * 100).round()}%.'
        : 'Clima: estación ${weather.season} (previsión detallada no disponible aún, el viaje es a más de 5 días vista).';
    final activitiesLine = trip.activities.isEmpty
        ? ''
        : '\n- Actividades específicas: ${trip.activities.map((a) => a.label).join(', ')}';
    final languageName = _languageName(language);

    return '''
Genera la lista de equipaje para este viaje:
- Destino: ${_destinationLine(trip)}
- Duración: ${trip.durationInDays} días (${trip.startDate.toIso8601String().split('T').first} a ${trip.endDate.toIso8601String().split('T').first})
- Tipo(s) de viaje: $types
- Número de personas: ${trip.peopleCount}
- $weatherLine$activitiesLine

Incluye documentación, electrónica, higiene, ropa (ajustada a los días de viaje y al clima) y cualquier artículo específico de los tipos de viaje y actividades indicados. Ajusta las cantidades al número de personas cuando el artículo sea personal (ej. cepillo de dientes, cargador). No incluyas artículos de lluvia si la probabilidad de lluvia indicada es baja. No incluyas más de 35 artículos, y no metas artículos "por si acaso" que no encajen con los datos anteriores — menos es mejor si es lo correcto para este viaje. Escribe el "name" de cada artículo en $languageName. Responde solo con el array JSON.
''';
  }

  /// Adjusts an already-generated list based on a free-text request from
  /// the user (e.g. "no llevo mucho espacio, optimiza la maleta"). Returns
  /// both the updated items and a short chat-style reply describing what
  /// changed, so the caller can show a small conversation around it.
  Future<AiRefineResult> refine({
    required Trip trip,
    required List<PackingItem> currentItems,
    required String instruction,
    String language = 'es',
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null) {
      throw StateError('OPENROUTER_API_KEY no configurada');
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-Title': 'Kipack',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.4,
        'reasoning': {'enabled': false},
        'messages': [
          {'role': 'system', 'content': _refineSystemPrompt(language)},
          {
            'role': 'user',
            'content': _refineUserPrompt(
              trip,
              currentItems,
              instruction,
              language,
            ),
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException(
        'OpenRouter respondió ${response.statusCode}: ${response.body}',
      );
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content =
        (body['choices'] as List<dynamic>).first['message']['content']
            as String;
    return _parseRefineResult(content);
  }

  String _refineSystemPrompt(String language) {
    final languageName = _languageName(language);
    return 'Eres un asistente que ajusta una lista de equipaje de viaje ya existente según lo que pida el '
        'usuario en lenguaje natural (por ejemplo: reducir volumen o número de artículos, quitar algo, '
        'añadir algo, adaptar la lista a una actividad concreta). Devuelve ÚNICAMENTE un objeto JSON '
        'con exactamente estas dos claves: '
        '"reply" (string en $languageName: una frase corta y concreta explicando qué has cambiado y por qué), '
        '"items" (el array COMPLETO de artículos ya actualizado — no solo los cambios — con el mismo '
        'formato de siempre: objetos con "name" (en $languageName, TODOS los artículos, no solo los nuevos), '
        '"category" (clothing/toiletries/electronics/documents/misc) '
        'y "quantity"). Nunca dejes "items" vacío salvo que el usuario pida explícitamente vaciar la lista. '
        'Sin texto adicional, sin markdown, sin backticks.'
        '${_spanishVocabNote(language)}';
  }

  String _refineUserPrompt(
    Trip trip,
    List<PackingItem> currentItems,
    String instruction,
    String language,
  ) {
    final itemsList = currentItems
        .map((i) => '- ${i.name} (${i.category.label}, cantidad ${i.quantity})')
        .join('\n');
    final languageName = _languageName(language);
    return '''
Viaje: ${_destinationLine(trip)}, ${trip.durationInDays} días, ${trip.peopleCount} persona(s).
Lista actual:
$itemsList

Petición del usuario: "$instruction"

Aplica el cambio pedido y responde con el objeto JSON descrito (reply + items), todo en $languageName.
''';
  }

  AiRefineResult _parseRefineResult(String content) {
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start == -1 || end == -1 || end < start) {
      throw const FormatException(
        'La respuesta de la IA no contiene un objeto JSON',
      );
    }
    final map =
        jsonDecode(content.substring(start, end + 1)) as Map<String, dynamic>;
    final reply = (map['reply'] as String?)?.trim();
    final rawItems = map['items'] as List<dynamic>?;
    if (reply == null || reply.isEmpty || rawItems == null) {
      throw const FormatException('Respuesta de la IA incompleta');
    }
    final items = _itemsFromRaw(rawItems);
    if (items.isEmpty) {
      throw const FormatException('La IA no devolvió ningún artículo válido');
    }
    return AiRefineResult(reply: reply, items: items);
  }

  List<PackingItem> _parseItems(String content) {
    final start = content.indexOf('[');
    final end = content.lastIndexOf(']');
    if (start == -1 || end == -1 || end < start) {
      throw const FormatException(
        'La respuesta de la IA no contiene un array JSON',
      );
    }
    final raw = jsonDecode(content.substring(start, end + 1)) as List<dynamic>;
    final items = _itemsFromRaw(raw);
    if (items.isEmpty) {
      throw const FormatException('La IA no devolvió ningún artículo válido');
    }
    return items;
  }

  List<PackingItem> _itemsFromRaw(List<dynamic> raw) {
    final items = <PackingItem>[];
    for (final entry in raw) {
      final map = entry as Map<String, dynamic>;
      final name = (map['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      final category = PackingCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => PackingCategory.misc,
      );
      final quantity = (map['quantity'] as num?)?.toInt() ?? 1;
      items.add(
        PackingItem(
          id: _uuid.v4(),
          name: name,
          category: category,
          quantity: quantity < 1 ? 1 : quantity,
        ),
      );
    }
    return items;
  }
}

class AiRefineResult {
  const AiRefineResult({required this.reply, required this.items});
  final String reply;
  final List<PackingItem> items;
}

class HttpException implements Exception {
  HttpException(this.message);
  final String message;
  @override
  String toString() => message;
}
