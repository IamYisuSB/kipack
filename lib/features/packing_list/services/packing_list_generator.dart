import 'package:uuid/uuid.dart';
import '../../trips/models/trip.dart';
import '../../trips/models/trip_activity.dart';
import '../../trips/models/trip_type.dart';
import '../models/packing_category.dart';
import '../models/packing_item.dart';

/// Generates a packing list for a [Trip].
///
/// This is a rule-based placeholder so the app's full flow (create trip ->
/// generate list -> manage list) works end to end today. It is designed to
/// be swapped later for a call to the AI + weather APIs without touching
/// any of the UI: same input (`Trip`), same output (`List&lt;PackingItem&gt;`).
class PackingListGenerator {
  const PackingListGenerator();

  static const _uuid = Uuid();

  Future<List<PackingItem>> generate(Trip trip) async {
    final items = <PackingItem>[];
    final addedNames = <String>{};
    void add(String name, PackingCategory category, {int quantity = 1}) {
      if (!addedNames.add(name)) return;
      items.add(
        PackingItem(
          id: _uuid.v4(),
          name: name,
          category: category,
          quantity: quantity,
        ),
      );
    }

    // Documents — always needed.
    add(
      'DNI / Pasaporte',
      PackingCategory.documents,
      quantity: trip.peopleCount,
    );
    add('Tarjetas y efectivo', PackingCategory.documents);
    add('Reservas y billetes', PackingCategory.documents);

    // Electronics — always needed.
    add(
      'Cargador de móvil',
      PackingCategory.electronics,
      quantity: trip.peopleCount,
    );
    add('Power bank', PackingCategory.electronics);
    add('Adaptador de enchufe', PackingCategory.electronics);

    // Toiletries — always needed.
    add(
      'Cepillo y pasta de dientes',
      PackingCategory.toiletries,
      quantity: trip.peopleCount,
    );
    add('Neceser básico', PackingCategory.toiletries);
    add('Protector solar', PackingCategory.toiletries);

    // Clothing — base by duration.
    final days = trip.durationInDays.clamp(1, 14);
    add('Camisetas', PackingCategory.clothing, quantity: days);
    add('Ropa interior', PackingCategory.clothing, quantity: days);
    add('Calcetines', PackingCategory.clothing, quantity: days);
    add('Pijama', PackingCategory.clothing);

    for (final type in trip.types) {
      switch (type) {
        case TripType.beach:
          add('Bañador', PackingCategory.clothing, quantity: 2);
          add('Chanclas', PackingCategory.clothing);
          add('Toalla de playa', PackingCategory.misc);
          add('Gafas de sol', PackingCategory.misc);
          add('Después del sol', PackingCategory.toiletries);
        case TripType.mountain:
          add('Chaqueta impermeable', PackingCategory.clothing);
          add('Botas de senderismo', PackingCategory.clothing);
          add('Forro polar', PackingCategory.clothing);
          add('Mochila de trekking', PackingCategory.misc);
          add('Linterna frontal', PackingCategory.electronics);
        case TripType.city:
          add('Calzado cómodo para caminar', PackingCategory.clothing);
          add('Ropa de abrigo ligera', PackingCategory.clothing);
          add('Cámara de fotos', PackingCategory.electronics);
        case TripType.business:
          add('Traje / ropa formal', PackingCategory.clothing, quantity: 2);
          add('Zapatos formales', PackingCategory.clothing);
          add('Portátil', PackingCategory.electronics);
          add('Tarjetas de presentación', PackingCategory.documents);
        case TripType.backpacker:
          add('Saco de dormir ligero', PackingCategory.misc);
          add('Candado de viaje', PackingCategory.misc);
          add('Botella reutilizable', PackingCategory.misc);
          add('Chanclas de ducha', PackingCategory.toiletries);
      }
    }

    for (final activity in trip.activities) {
      switch (activity) {
        case TripActivity.diving:
          add('Gafas y tubo de buceo', PackingCategory.misc);
          add('Traje de neopreno', PackingCategory.clothing);
          add('Toalla de secado rápido', PackingCategory.misc);
        case TripActivity.hiking:
          add('Botas de senderismo', PackingCategory.clothing);
          add('Bastones de trekking', PackingCategory.misc);
          add('Mochila de senderismo', PackingCategory.misc);
        case TripActivity.skiing:
          add('Chaqueta de esquí', PackingCategory.clothing);
          add('Guantes térmicos', PackingCategory.clothing);
          add('Gafas de nieve', PackingCategory.misc);
          add('Crema solar de alta protección', PackingCategory.toiletries);
        case TripActivity.surfing:
          add('Traje de neopreno', PackingCategory.clothing);
          add('Cera para tabla de surf', PackingCategory.misc);
        case TripActivity.cycling:
          add('Casco de ciclismo', PackingCategory.misc);
          add('Guantes de ciclismo', PackingCategory.clothing);
        case TripActivity.camping:
          add('Tienda de campaña', PackingCategory.misc);
          add('Saco de dormir', PackingCategory.misc);
          add('Linterna frontal', PackingCategory.electronics);
        case TripActivity.photography:
          add('Cámara de fotos', PackingCategory.electronics);
          add(
            'Baterías y tarjetas de memoria extra',
            PackingCategory.electronics,
          );
          add('Trípode', PackingCategory.misc);
        case TripActivity.running:
          add('Zapatillas de running', PackingCategory.clothing);
          add(
            'Ropa técnica transpirable',
            PackingCategory.clothing,
            quantity: days,
          );
      }
    }

    final weather = trip.weather;
    if (weather != null && weather.hasForecast) {
      if (weather.willLikelyRain) {
        add('Paraguas plegable', PackingCategory.misc);
        add('Chaqueta impermeable', PackingCategory.clothing);
      }
      if (weather.isCold) {
        add('Abrigo de invierno', PackingCategory.clothing);
        add('Guantes y bufanda', PackingCategory.clothing);
      }
      if (weather.isHot) {
        add(
          'Ropa ligera y transpirable',
          PackingCategory.clothing,
          quantity: days,
        );
        add('Gorra o sombrero', PackingCategory.misc);
      }
    }

    return items;
  }
}
