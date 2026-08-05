import 'packing_category.dart';

/// A single line within a saved template — deliberately slimmer than
/// [PackingItem]: a template has no packed/suitcase state, those only make
/// sense for a specific trip's list.
class TemplateItem {
  const TemplateItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final PackingCategory category;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'quantity': quantity,
  };

  factory TemplateItem.fromJson(Map<String, dynamic> json) => TemplateItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: PackingCategory.values.byName(json['category'] as String),
    quantity: json['quantity'] as int,
  );
}

/// A reusable, hand-curated packing checklist (e.g. "Negocios", "Playa")
/// built by adding items directly — not a snapshot of a generated trip
/// list, so it only ever contains what the user deliberately put in it
/// (typically weather-independent things: documents, chargers, etc.).
class PackingTemplate {
  PackingTemplate({required this.id, required this.name, required this.items});

  final String id;
  final String name;
  final List<TemplateItem> items;

  PackingTemplate copyWith({List<TemplateItem>? items}) {
    return PackingTemplate(id: id, name: name, items: items ?? this.items);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((i) => i.toJson()).toList(),
  };

  factory PackingTemplate.fromJson(Map<String, dynamic> json) =>
      PackingTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        items: (json['items'] as List<dynamic>)
            .map((i) => TemplateItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}
