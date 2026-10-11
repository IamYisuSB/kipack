import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/packing_item.dart';
import '../models/suitcase.dart';

class PackingItemTile extends StatelessWidget {
  const PackingItemTile({
    super.key,
    required this.item,
    required this.suitcases,
    required this.onToggle,
    required this.onRemove,
    required this.onAssignSuitcase,
  });

  final PackingItem item;
  final List<Suitcase> suitcases;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final ValueChanged<String?> onAssignSuitcase;


  Suitcase? get _assignedSuitcase {
    if (item.suitcaseId == null) return null;
    for (final s in suitcases) {
      if (s.id == item.suitcaseId) return s;
    }
    return null;
  }

  Future<void> _pickSuitcase(BuildContext context) async {
    final result = await showModalBottomSheet<_SuitcasePickResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).assignSuitcaseTitle,
                style: AppTextStyles.title.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.remove_circle_outline_rounded),
                title: Text(AppLocalizations.of(context).assignSuitcaseNone),
                onTap: () => Navigator.of(
                  context,
                ).pop(const _SuitcasePickResult.unassign()),
              ),
              for (final s in suitcases)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.luggage_rounded),
                  title: Text(s.name),
                  onTap: () => Navigator.of(
                    context,
                  ).pop(_SuitcasePickResult.assign(s.id)),
                ),
              if (suitcases.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppLocalizations.of(context).assignSuitcaseEmptyHint,
                    style: AppTextStyles.body.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
    if (result != null) onAssignSuitcase(result.suitcaseId);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final assigned = _assignedSuitcase;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.isPacked
                              ? item.category.color
                              : Colors.transparent,
                          border: Border.all(
                            color: item.isPacked
                                ? item.category.color
                                : (secondary ?? Colors.grey),
                            width: 1.6,
                          ),
                        ),
                        child: item.isPacked
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: AppTextStyles.body.copyWith(
                            color: item.isPacked ? secondary : onSurface,
                            decoration: item.isPacked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          child: Text(item.name),
                        ),
                      ),
                      if (item.quantity > 1)
                        Text(
                          'x${item.quantity}',
                          style: AppTextStyles.caption.copyWith(
                            color: secondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _pickSuitcase(context),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.luggage_rounded,
                  size: 18,
                  color: assigned != null
                      ? Theme.of(context).colorScheme.primary
                      : secondary?.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuitcasePickResult {
  const _SuitcasePickResult.assign(this.suitcaseId);
  const _SuitcasePickResult.unassign() : suitcaseId = null;

  final String? suitcaseId;
}
