class TripCollaborator {
  const TripCollaborator({
    required this.id,
    required this.invitedEmail,
    this.userId,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String invitedEmail;

  /// Null until this invite is accepted (see `accept_trip_invite` in the
  /// database, called from `PendingInvitesNotifier.accept`).
  final String? userId;

  /// Only populated once the invite is claimed — comes from the joined
  /// `profiles` row, which the RLS policy only exposes to other members of
  /// a shared trip (see `shares_trip_with`), never to arbitrary users.
  final String? displayName;
  final String? avatarUrl;

  bool get hasJoined => userId != null;

  factory TripCollaborator.fromRow(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map<String, dynamic>?;
    return TripCollaborator(
      id: row['id'] as String,
      invitedEmail: row['invited_email'] as String,
      userId: row['user_id'] as String?,
      displayName: profile?['display_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }
}
