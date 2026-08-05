import 'package:countries_world_map/data/maps/world_map.dart';
// ignore: implementation_imports
import 'package:countries_world_map/src/helpers/map_attributes.dart';
// ignore: implementation_imports
import 'package:countries_world_map/src/helpers/map_instructions.dart';
import 'package:flutter/material.dart';

/// Renders a single country's outline (extracted from `countries_world_map`'s
/// world-map path data) as a small standalone icon — e.g. Italy's boot.
///
/// Falls back to [fallback] when [countryCode] is null or isn't one of the
/// ~250 territories the package covers.
class CountryShapeIcon extends StatelessWidget {
  const CountryShapeIcon({
    super.key,
    required this.countryCode,
    required this.color,
    required this.fallback,
    this.size = 26,
  });

  final String? countryCode;
  final Color color;
  final Widget fallback;
  final double size;

  static MapAttributes? _attributes;
  static Map<String, SimpleMapInstruction>? _byId;

  static void _ensureLoaded() {
    if (_attributes != null) return;
    final attributes = MapAttributes(SMapWorld.instructions);
    _attributes = attributes;
    final byId = <String, SimpleMapInstruction>{};
    final bestArea = <String, double>{};
    for (final raw in attributes.drawingInstructions) {
      final candidate = SimpleMapInstruction.fromJson(raw);
      // Countries with overseas territories (Spain's Canary Islands, France's
      // Corsica, etc.) show up as several disconnected polygons sharing the
      // same country code. Keeping "whichever is last in the data" can leave
      // a tiny offshore island as the icon instead of the mainland — keep
      // the largest polygon per code instead.
      final id = candidate.uniqueID;
      final area = _boundsArea(candidate.instructions);
      if (!bestArea.containsKey(id) || area > bestArea[id]!) {
        bestArea[id] = area;
        byId[id] = candidate;
      }
    }
    _byId = byId;
  }

  static double _boundsArea(List<String> instructions) {
    double? minX, minY, maxX, maxY;
    for (final raw in instructions) {
      if (raw == 'c') continue;
      final coords = raw.substring(1).split(',');
      final x = double.parse(coords[0]);
      final y = double.parse(coords[1]);
      minX = minX == null || x < minX ? x : minX;
      minY = minY == null || y < minY ? y : minY;
      maxX = maxX == null || x > maxX ? x : maxX;
      maxY = maxY == null || y > maxY ? y : maxY;
    }
    if (minX == null) return 0;
    return (maxX! - minX) * (maxY! - minY!);
  }

  @override
  Widget build(BuildContext context) {
    final code = countryCode?.toLowerCase();
    if (code == null) return fallback;

    _ensureLoaded();
    final instruction = _byId![code];
    if (instruction == null) return fallback;

    final mapWidth = _attributes!.mapWidth;
    final mapHeight = _attributes!.mapHeight;
    final path = Path();
    for (final raw in instruction.instructions) {
      if (raw == 'c') {
        path.close();
        continue;
      }
      final coords = raw.substring(1).split(',');
      final x = double.parse(coords[0]) * mapWidth;
      final y = double.parse(coords[1]) * mapHeight;
      if (raw[0] == 'm') path.moveTo(x, y);
      if (raw[0] == 'l') path.lineTo(x, y);
    }
    final bounds = path.getBounds();
    if (bounds.width == 0 || bounds.height == 0) return fallback;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CountrySilhouettePainter(
          path: path,
          bounds: bounds,
          color: color,
        ),
      ),
    );
  }
}

class _CountrySilhouettePainter extends CustomPainter {
  _CountrySilhouettePainter({
    required this.path,
    required this.bounds,
    required this.color,
  });

  final Path path;
  final Rect bounds;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // A silhouette is a solid filled shape with no internal detail, so
    // scaling it to completely fill its box (touching all four edges) reads
    // as much "bigger" than a normal outline icon of the same nominal size.
    // Leaving a margin makes it sit inside its background the way a regular
    // icon glyph does.
    const fillFraction = 0.72;
    final scaleX = (size.width * fillFraction) / bounds.width;
    final scaleY = (size.height * fillFraction) / bounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final dx = (size.width - bounds.width * scale) / 2 - bounds.left * scale;
    final dy = (size.height - bounds.height * scale) / 2 - bounds.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CountrySilhouettePainter oldDelegate) =>
      oldDelegate.path != path || oldDelegate.color != color;
}
