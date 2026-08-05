import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../trips/models/trip_collaborator.dart';
import '../../trips/models/trip_member_profile.dart';
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
    this.collaborators = const [],
    this.currentUserId,
    this.onAssignPerson,
    this.memberProfiles = const {},
  });

  final PackingItem item;
  final List<Suitcase> suitcases;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final ValueChanged<String?> onAssignSuitcase;

  /// Only non-empty for shared trips — the assignment picker is skipped
  /// entirely when there's nobody to assign to.
  final List<TripCollaborator> collaborators;
  final String? currentUserId;
  final ValueChanged<String?>? onAssignPerson;
  final Map<String, TripMemberProfile> memberProfiles;

  /// Once someone has packed a shared item, only they can un-pack it —
  /// stops one collaborator from silently undoing another's work. Doesn't
  /// apply to solo trips (no collaborators) or unassigned items.
  bool get _lockedForOthers =>
      collaborators.isNotEmpty &&
      item.isPacked &&
      item.assignedUserId != null &&
      item.assignedUserId != currentUserId;

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

  Future<void> _pickPerson(BuildContext context) async {
    final joined = collaborators.where((c) => c.hasJoined).toList();
    final result = await showModalBottomSheet<_PersonPickResult>(
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
                AppLocalizations.of(context).assignPersonTitle,
                style: AppTextStyles.title.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.remove_circle_outline_rounded),
                title: Text(AppLocalizations.of(context).assignPersonNone),
                onTap: () => Navigator.of(
                  context,
                ).pop(const _PersonPickResult.unassign()),
              ),
              if (currentUserId != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_rounded),
                  title: Text(AppLocalizations.of(context).assignPersonYou),
                  onTap: () => Navigator.of(
                    context,
                  ).pop(_PersonPickResult.assign(currentUserId!)),
                ),
              for (final c in joined)
                if (c.userId != currentUserId)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(c.invitedEmail),
                    onTap: () => Navigator.of(
                      context,
                    ).pop(_PersonPickResult.assign(c.userId!)),
                  ),
            ],
          ),
        );
      },
    );
    if (result != null) onAssignPerson?.call(result.userId);
  }

  void _handleTogglePacked(BuildContext context) {
    if (_lockedForOthers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).packingItemLocked)),
      );
      return;
    }
    onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final assigned = _assignedSuitcase;
    final packerProfile = item.assignedUserId == null
        ? null
        : memberProfiles[item.assignedUserId];

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
                onTap: () => _handleTogglePacked(context),
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
            if (collaborators.isNotEmpty)
              InkWell(
                // Locked while packed — the avatar shown *is* who packed
                // it; reassigning without unpacking first would silently
                // steal credit and defeat the "only they can unpack" rule.
                onTap: item.isPacked ? null : () => _pickPerson(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: item.assignedUserId != null
                      ? _PackerAvatar(profile: packerProfile)
                      : Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: secondary?.withValues(alpha: 0.5),
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

class _PersonPickResult {
  const _PersonPickResult.assign(this.userId);
  const _PersonPickResult.unassign() : userId = null;

  final String? userId;
}

/// Small circular avatar for whoever packed an item — their photo if
/// they've set one, otherwise the first letter of their name. Falls back
/// to a generic icon if [profile] hasn't loaded yet (e.g. the owner's
/// profile is still being fetched).
class _PackerAvatar extends StatelessWidget {
  const _PackerAvatar({required this.profile, this.size = 20});

  final TripMemberProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = profile?.avatarUrl;
    if (url != null) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitial(),
        ),
      );
    }
    return _buildInitial();
  }

  Widget _buildInitial() {
    final name = profile?.displayName;
    final initial = (name?.isNotEmpty == true ? name![0] : '?').toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
