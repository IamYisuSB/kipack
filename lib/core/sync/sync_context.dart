import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../premium/premium_provider.dart';

/// Cloud sync (trips, packing lists, suitcases) only runs for signed-in
/// Premium users — free/guest mode stays entirely local, same as before
/// any of this existed.
bool canSync(Ref ref) =>
    ref.read(premiumProvider) && currentUserId(ref) != null;

String? currentUserId(Ref ref) => ref.read(authStateProvider).asData?.value?.id;
