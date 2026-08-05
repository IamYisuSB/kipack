/// A trip-collaborator invite addressed to the current user's email that
/// hasn't been accepted or declined yet — see `get_pending_invites` in the
/// database (a SECURITY DEFINER function, since RLS on `trips` normally
/// wouldn't let someone see a trip they aren't a member of yet).
class PendingInvite {
  const PendingInvite({
    required this.inviteId,
    required this.tripId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.inviterName,
  });

  final String inviteId;
  final String tripId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;

  /// Null if the inviter never set a display name.
  final String? inviterName;

  factory PendingInvite.fromRow(Map<String, dynamic> row) => PendingInvite(
    inviteId: row['invite_id'] as String,
    tripId: row['trip_id'] as String,
    destination: row['destination'] as String,
    startDate: DateTime.parse(row['start_date'] as String),
    endDate: DateTime.parse(row['end_date'] as String),
    inviterName: row['inviter_name'] as String?,
  );
}
