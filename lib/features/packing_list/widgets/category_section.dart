import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../trips/models/trip_collaborator.dart';
import '../../trips/models/trip_member_profile.dart';
import '../models/packing_category.dart';
import '../models/packing_item.dart';
import '../models/suitcase.dart';
import 'packing_item_tile.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.suitcases,
    required this.onToggle,
    required this.onRemove,
    required this.onAssignSuitcase,
    this.collaborators = const [],
    this.currentUserId,
    this.onAssignPerson,
    this.memberProfiles = const {},
  });

  final PackingCategory category;
  final List<PackingItem> items;
  final List<Suitcase> suitcases;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onRemove;
  final void Function(String itemId, String? suitcaseId) onAssignSuitcase;
  final List<TripCollaborator> collaborators;
  final String? currentUserId;
  final void Function(String itemId, String? userId)? onAssignPerson;

  /// Display name/avatar for every trip owner+collaborator, keyed by user
  /// id — used to show who packed an item. See `PackingListScreen` for how
  /// this is assembled (collaborators list + a separate owner lookup).
  final Map<String, TripMemberProfile> memberProfiles;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final packed = items.where((i) => i.isPacked).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(category.icon, color: category.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.displayLabel(context),
                  style: AppTextStyles.subtitle.copyWith(color: onSurface),
                ),
              ),
              Text(
                '$packed/${items.length}',
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...items.map(
            (item) => PackingItemTile(
              item: item,
              suitcases: suitcases,
              onToggle: () => onToggle(item.id),
              onRemove: () => onRemove(item.id),
              onAssignSuitcase: (suitcaseId) =>
                  onAssignSuitcase(item.id, suitcaseId),
              collaborators: collaborators,
              currentUserId: currentUserId,
              onAssignPerson: onAssignPerson == null
                  ? null
                  : (userId) => onAssignPerson!(item.id, userId),
              memberProfiles: memberProfiles,
            ),
          ),
        ],
      ),
    );
  }
}
