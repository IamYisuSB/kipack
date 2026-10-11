import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_store.dart';

const _storageKey = 'manually_visited_countries';

/// Countries the user has manually marked as visited on the map,
/// independent of any trip (e.g. a country they've been to before this app
/// existed). Countries tied to an actual trip are colored separately in
/// [TripsMapScreen] and take priority — those can only be cleared by
/// deleting the trip, not by tapping the map.
class VisitedCountriesNotifier extends StateNotifier<Set<String>> {
  VisitedCountriesNotifier() : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    state = await LocalStore.instance.readStringSet(_storageKey);
  }

  Future<void> toggle(String countryCode) async {
    final next = {...state};
    if (!next.remove(countryCode)) next.add(countryCode);
    state = next;
    await LocalStore.instance.writeStringSet(_storageKey, state);
  }
}

final visitedCountriesProvider =
    StateNotifierProvider<VisitedCountriesNotifier, Set<String>>((ref) {
      return VisitedCountriesNotifier();
    });
