import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/pending_invite.dart';
import '../providers/pending_invites_provider.dart';

/// Shown at the top of the trips list when there are pending share
/// invites — lets the user accept or decline right there, no separate
/// inbox screen needed since there's rarely more than one or two at once.
class PendingInvitesBanner extends ConsumerWidget {
  const PendingInvitesBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(pendingInvitesProvider);
    if (invites.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final invite in invites)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _InviteCard(invite: invite),
          ),
      ],
    );
  }
}

class _InviteCard extends ConsumerStatefulWidget {
  const _InviteCard({required this.invite});

  final PendingInvite invite;

  @override
  ConsumerState<_InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends ConsumerState<_InviteCard> {
  bool _isBusy = false;
  String? _error;

  Future<void> _respond(bool accept) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final notifier = ref.read(pendingInvitesProvider.notifier);
      if (accept) {
        await notifier.accept(widget.invite.inviteId);
      } else {
        await notifier.decline(widget.invite.inviteId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = AppLocalizations.of(context).pendingInviteActionError,
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inviterName = widget.invite.inviterName;

    return Material(
      color: AppColors.accentSoft,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    inviterName != null
                        ? l10n.pendingInviteWithName(
                            inviterName,
                            widget.invite.destination,
                          )
                        : l10n.pendingInviteWithoutName(
                            widget.invite.destination,
                          ),
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isBusy ? null : () => _respond(false),
                  child: Text(l10n.pendingInviteDecline),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _isBusy ? null : () => _respond(true),
                  child: _isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.pendingInviteAccept),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
