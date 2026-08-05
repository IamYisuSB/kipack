/// Minimal display info (name + photo) for a trip owner or collaborator —
/// used to show whose avatar packed a given item. Separate from
/// [TripCollaborator] because the owner needs the same info too, and the
/// owner never has a `trip_collaborators` row (they're not invited to
/// their own trip).
class TripMemberProfile {
  const TripMemberProfile({this.displayName, this.avatarUrl});

  final String? displayName;
  final String? avatarUrl;
}
