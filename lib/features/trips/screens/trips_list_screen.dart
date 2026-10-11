import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ads/banner_ad_slot.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../packing_list/providers/packing_list_provider.dart';
import '../../packing_list/providers/suitcases_provider.dart';
import '../../packing_list/screens/packing_list_screen.dart';
import '../../weather/models/trip_weather.dart';
import '../../weather/services/weather_service.dart';
import '../models/trip.dart';
import '../providers/trips_provider.dart';
import '../services/reminders_service.dart';
import '../widgets/trip_card.dart';
import 'new_trip_screen.dart';

enum _TripFilter { all, upcoming, past }

class TripsListScreen extends ConsumerStatefulWidget {
  const TripsListScreen({super.key});

  @override
  ConsumerState<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends ConsumerState<TripsListScreen> {
  static const _weatherService = WeatherService();

  final _searchController = TextEditingController();
  String _query = '';
  _TripFilter _filter = _TripFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final selectedChipFg = AppColors.chipSelectedForeground(context);
    final l10n = AppLocalizations.of(context);

    final query = _query.trim().toLowerCase();
    final filtered = trips.where((trip) {
      final matchesQuery =
          query.isEmpty || trip.destination.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        _TripFilter.all => true,
        _TripFilter.upcoming => !trip.isVisited,
        _TripFilter.past => trip.isVisited,
      };
      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tripsListTitle,
                        style: AppTextStyles.display.copyWith(color: onSurface),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.tripsListSubtitle,
                        style: AppTextStyles.body.copyWith(color: secondary),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                sliver: const SliverToBoxAdapter(child: BannerAdSlot()),
              ),
              if (trips.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText: l10n.tripsListSearchHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(
                                l10n.tripsFilterAll,
                                style: _filter == _TripFilter.all
                                    ? TextStyle(color: selectedChipFg)
                                    : null,
                              ),
                              selected: _filter == _TripFilter.all,
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _filter = _TripFilter.all),
                            ),
                            ChoiceChip(
                              label: Text(
                                l10n.tripsFilterUpcoming,
                                style: _filter == _TripFilter.upcoming
                                    ? TextStyle(color: selectedChipFg)
                                    : null,
                              ),
                              selected: _filter == _TripFilter.upcoming,
                              showCheckmark: false,
                              onSelected: (_) => setState(
                                () => _filter = _TripFilter.upcoming,
                              ),
                            ),
                            ChoiceChip(
                              label: Text(
                                l10n.tripsFilterPast,
                                style: _filter == _TripFilter.past
                                    ? TextStyle(color: selectedChipFg)
                                    : null,
                              ),
                              selected: _filter == _TripFilter.past,
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _filter = _TripFilter.past),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (trips.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(onCreate: () => _openNewTrip(context)),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NoResultsState(secondary: secondary),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final trip = filtered[index];
                      return TripCard(
                        trip: trip,
                        onTap: () => _openPackingList(context, trip),
                        onDuplicate: () => _duplicateTrip(context, ref, trip),
                        onDelete: () => _confirmDelete(context, ref, trip),
                      );
                    },
                  ),
                ),
            ],
          ),
      ),
      floatingActionButton: trips.isEmpty
          ? null
          // Lifted clear of the floating glass nav bar below (that bar isn't
          // part of this Scaffold, so it wouldn't otherwise know to leave
          // room for it).
          : Padding(
              padding: const EdgeInsets.only(bottom: 76),
              child: FloatingActionButton.extended(
                onPressed: () => _openNewTrip(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.newTripButton),
              ),
            ),
    );
  }

  void _openNewTrip(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewTripScreen()));
  }

  void _openPackingList(BuildContext context, Trip trip) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PackingListScreen(trip: trip)));
  }

  Future<void> _duplicateTrip(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
  ) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: AppLocalizations.of(
        context,
      ).duplicateTripNewDatesFor(trip.destination),
    );
    if (range == null || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // The duplicate almost always lands on different dates than the
    // original (different season, sometimes a different year), so the old
    // trip's weather snapshot can't just be copied — it has to be
    // refetched for the new date range, same as a brand-new trip does.
    final language = Localizations.localeOf(context).languageCode;
    TripWeather? weather;
    try {
      final location = await _weatherService.geocodeDestination(
        trip.destination,
        language: language,
      );
      if (location != null) {
        weather = await _weatherService.fetchWeatherForLocation(
          location: location,
          startDate: range.start,
          endDate: range.end,
        );
      }
    } catch (_) {
      // Best-effort — a duplicated trip without weather is still usable.
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();

    final newTrip = ref
        .read(tripsProvider.notifier)
        .addTrip(
          destination: trip.destination,
          startDate: range.start,
          endDate: range.end,
          types: trip.types,
          peopleCount: trip.peopleCount,
          activities: trip.activities,
          weather: weather,
          countryCode: trip.countryCode,
        );

    final sourceSuitcases = ref.read(suitcasesProvider(trip.id));
    if (sourceSuitcases.isNotEmpty) {
      ref
          .read(suitcasesProvider(newTrip.id).notifier)
          .seedSuitcases(sourceSuitcases);
    }

    final sourceItems = ref.read(packingListProvider(trip.id));
    if (sourceItems.isNotEmpty) {
      final copied = sourceItems
          .map((i) => i.copyWith(isPacked: false))
          .toList();
      ref.read(packingListProvider(newTrip.id).notifier).seedItems(copied);
    }

    if (!context.mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PackingListScreen(trip: newTrip)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTripTitle),
        content: Text(l10n.deleteTripConfirm(trip.destination)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.commonDelete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(tripsProvider.notifier).removeTrip(trip.id);
      RemindersService.instance.cancelTripReminders(trip.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_travel_rounded,
                size: 44,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.tripsEmptyTitle,
              style: AppTextStyles.title.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tripsEmptyBody,
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.newTripButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.secondary});

  final Color? secondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: secondary),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).tripsNoResults,
              style: AppTextStyles.body.copyWith(color: secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
