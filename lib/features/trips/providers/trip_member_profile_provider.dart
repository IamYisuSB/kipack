import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/profile_service.dart';
import '../models/trip_member_profile.dart';

/// Fetches (and Riverpod-caches) the display name + avatar for a single
/// user id — used specifically for a trip's *owner*, since collaborators
/// already carry this info from `collaboratorsProvider`'s joined query,
/// but the owner has no `trip_collaborators` row to join from. RLS's
/// `shares_trip_with` policy is what allows this to succeed for another
/// member of the same trip, not just your own profile.
final tripMemberProfileProvider =
    FutureProvider.family<TripMemberProfile?, String>((ref, userId) async {
      final results = await Future.wait([
        profileService.fetchDisplayName(userId),
        profileService.fetchAvatarUrl(userId),
      ]);
      return TripMemberProfile(displayName: results[0], avatarUrl: results[1]);
    });
