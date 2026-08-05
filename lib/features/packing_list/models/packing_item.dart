import 'packing_category.dart';

class PackingItem {
  PackingItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isPacked = false,
    this.suitcaseId,
    this.assignedUserId,
  });

  final String id;
  final String name;
  final PackingCategory category;
  final int quantity;
  final bool isPacked;
  final String? suitcaseId;

  /// Supabase user id of the collaborator this item is assigned to — "cada
  /// acompañante marca lo suyo". Null means unassigned; only meaningful
  /// for shared trips.
  final String? assignedUserId;

  static const _unset = Object();

  /// Pass `suitcaseId`/`assignedUserId: null` to explicitly unassign; omit
  /// to leave unchanged.
  PackingItem copyWith({
    String? name,
    PackingCategory? category,
    int? quantity,
    bool? isPacked,
    Object? suitcaseId = _unset,
    Object? assignedUserId = _unset,
  }) {
    return PackingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isPacked: isPacked ?? this.isPacked,
      suitcaseId: identical(suitcaseId, _unset)
          ? this.suitcaseId
          : suitcaseId as String?,
      assignedUserId: identical(assignedUserId, _unset)
          ? this.assignedUserId
          : assignedUserId as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'quantity': quantity,
    'isPacked': isPacked,
    'suitcaseId': suitcaseId,
    'assignedUserId': assignedUserId,
  };

  factory PackingItem.fromJson(Map<String, dynamic> json) => PackingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: PackingCategory.values.byName(json['category'] as String),
    quantity: json['quantity'] as int,
    isPacked: json['isPacked'] as bool,
    suitcaseId: json['suitcaseId'] as String?,
    assignedUserId: json['assignedUserId'] as String?,
  );
}
