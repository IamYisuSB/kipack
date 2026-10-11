import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../core/data/country_catalog.dart';
import '../../trips/models/trip.dart';
import '../models/packing_category.dart';
import '../models/packing_item.dart';

/// Generates and refines packing lists through Kipack's own AI proxy (a
/// Cloudflare Worker, see `worker/` at the repo root). The proxy holds the
/// OpenRouter key and builds the prompts — the app only sends trip data,
/// so no AI provider key ships inside the APK.
///
/// Throws on any failure (missing config, network, rate limit, bad
/// response) so the caller can fall back to [PackingListGenerator] — this
/// class never silently returns an empty/partial list.
class AiPackingListService {
  const AiPackingListService();

  static const _uuid = Uuid();
  static const _timeout = Duration(seconds: 90);

  String? _env(String name) {
    final value = dotenv.maybeGet(name)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  bool get isConfigured =>
      _env('KIPACK_AI_URL') != null && _env('KIPACK_AI_TOKEN') != null;

  /// "Singa" alone is genuinely ambiguous — it's also a real, small place in
  /// Huánuco, Perú, and a model given just that bare name will happily
  /// "correct" it to Singapur. `trip.destination` only stores the bare place
  /// name, so this appends the country captured at geocoding time.
  String _destinationLine(Trip trip) {
    final countryCode = trip.countryCode;
    if (countryCode == null) return trip.destination;
    return '${trip.destination}, ${countryDisplayName(countryCode)}';
  }

  String _date(DateTime date) => date.toIso8601String().split('T').first;

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final baseUrl = _env('KIPACK_AI_URL');
    final token = _env('KIPACK_AI_TOKEN');
    if (baseUrl == null || token == null) {
      throw StateError('KIPACK_AI_URL / KIPACK_AI_TOKEN no configurados');
    }
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {
            'Content-Type': 'application/json',
            'X-Kipack-Token': token,
          },
          body: jsonEncode(payload),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw HttpException(
        'Kipack AI respondió ${response.statusCode}: ${response.body}',
      );
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  Future<List<PackingItem>> generate(
    Trip trip, {
    String language = 'es',
  }) async {
    final weather = trip.weather;
    final body = await _post('/v1/generate', {
      'language': language,
      'destination': _destinationLine(trip),
      'startDate': _date(trip.startDate),
      'endDate': _date(trip.endDate),
      'durationDays': trip.durationInDays,
      'types': trip.types.map((t) => t.label).toList(),
      'activities': trip.activities.map((a) => a.label).toList(),
      'peopleCount': trip.peopleCount,
      'weather': weather == null
          ? null
          : {
              'season': weather.season,
              if (weather.hasForecast) ...{
                'minC': weather.avgMinTempC,
                'maxC': weather.avgMaxTempC,
                'rainPct': weather.rainProbability == null
                    ? null
                    : weather.rainProbability! * 100,
              },
            },
    });
    final items = _itemsFromRaw(body['items'] as List<dynamic>? ?? const []);
    if (items.isEmpty) {
      throw const FormatException('La IA no devolvió ningún artículo válido');
    }
    return items;
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
    final body = await _post('/v1/refine', {
      'language': language,
      'destination': _destinationLine(trip),
      'durationDays': trip.durationInDays,
      'peopleCount': trip.peopleCount,
      'items': [
        for (final item in currentItems)
          {
            'name': item.name,
            'category': item.category.name,
            'quantity': item.quantity,
          },
      ],
      'instruction': instruction,
    });
    final reply = (body['reply'] as String?)?.trim();
    final items = _itemsFromRaw(body['items'] as List<dynamic>? ?? const []);
    if (reply == null || reply.isEmpty || items.isEmpty) {
      throw const FormatException('Respuesta de la IA incompleta');
    }
    return AiRefineResult(reply: reply, items: items);
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
