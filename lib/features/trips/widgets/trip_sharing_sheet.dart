import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/collaborators_provider.dart';

/// Invite/remove people on a shared trip. Anyone can open this to see who's
/// on the trip; only the owner sees the invite field and remove buttons —
/// enforced here for a clean UI, and by RLS on the server regardless.
class TripSharingSheet extends ConsumerStatefulWidget {
  const TripSharingSheet({
    super.key,
    required this.tripId,
    required this.isOwner,
  });

  final String tripId;
  final bool isOwner;

  @override
  ConsumerState<TripSharingSheet> createState() => _TripSharingSheetState();
}

class _TripSharingSheetState extends ConsumerState<TripSharingSheet> {
  final _emailController = TextEditingController();
  bool _isInviting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _isInviting) return;
    setState(() {
      _isInviting = true;
      _error = null;
    });
    try {
      await ref
          .read(collaboratorsProvider(widget.tripId).notifier)
          .invite(email);
      _emailController.clear();
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = AppLocalizations.of(context).sharingSheetInviteError,
      );
    } finally {
      if (mounted) setState(() => _isInviting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collaborators = ref.watch(collaboratorsProvider(widget.tripId));
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
              l10n.sharingSheetTitle,
              style: AppTextStyles.title.copyWith(color: onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sharingSheetSubtitle,
              style: AppTextStyles.body.copyWith(color: secondary),
            ),
            const SizedBox(height: 16),
            if (collaborators.isEmpty)
              Text(
                l10n.sharingSheetEmpty,
                style: AppTextStyles.body.copyWith(color: secondary),
              )
            else
              ...collaborators.map(
                (c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: c.hasJoined
                      ? _CollaboratorAvatar(
                          displayName: c.displayName,
                          avatarUrl: c.avatarUrl,
                          email: c.invitedEmail,
                        )
                      : Icon(Icons.hourglass_empty_rounded, color: secondary),
                  title: Text(c.invitedEmail),
                  subtitle: Text(
                    c.hasJoined
                        ? l10n.sharingSheetHasAccess
                        : l10n.sharingSheetPending,
                  ),
                  trailing: widget.isOwner
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => ref
                              .read(
                                collaboratorsProvider(widget.tripId).notifier,
                              )
                              .remove(c.id),
                        )
                      : null,
                ),
              ),
            if (widget.isOwner) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: l10n.sharingSheetInviteHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isInviting ? null : _invite,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                l10n.sharingSheetInviteFootnote,
                style: AppTextStyles.caption.copyWith(color: secondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A joined collaborator's photo, falling back to their first initial (from
/// their display name, or their email if they never set one) when they
/// haven't set a profile photo.
class _CollaboratorAvatar extends StatelessWidget {
  const _CollaboratorAvatar({
    required this.displayName,
    required this.avatarUrl,
    required this.email,
  });

  final String? displayName;
  final String? avatarUrl;
  final String email;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url != null) {
      return ClipOval(
        child: Image.network(
          url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitial(),
        ),
      );
    }
    return _buildInitial();
  }

  Widget _buildInitial() {
    final source =
        (displayName?.isNotEmpty == true ? displayName : email) ?? '';
    final initial = source.isNotEmpty ? source[0].toUpperCase() : '?';
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.bodyStrong.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
