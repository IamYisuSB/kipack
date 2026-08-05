import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/data/country_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../packing_list/screens/packing_list_screen.dart';
import '../../trips/models/trip.dart';
import '../../trips/providers/trips_provider.dart';
import '../providers/visited_countries_provider.dart';

class TripsMapScreen extends ConsumerStatefulWidget {
  const TripsMapScreen({super.key});

  @override
  ConsumerState<TripsMapScreen> createState() => _TripsMapScreenState();
}

class _TripsMapScreenState extends ConsumerState<TripsMapScreen> {
  static const _visitedColor = AppColors.success;
  static const _plannedColor = AppColors.accent;
  static const _manualColor = AppColors.mapManualVisited;
  static const _minScale = 1.0;
  static const _maxScale = 6.0;
  // Intrinsic aspect ratio (w/h) of SMapWorld's source data (2000x857).
  static const _mapAspectRatio = 2000 / 857;

  final _transformationController = TransformationController();
  final _viewerKey = GlobalKey();
  bool _didCenter = false;
  bool _countriesExpanded = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoom(double factor) {
    final renderBox =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);

    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final targetScale = (currentScale * factor).clamp(_minScale, _maxScale);
    final actualFactor = targetScale / currentScale;
    if (actualFactor == 1.0) return;

    final matrix = _transformationController.value.clone()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(actualFactor, actualFactor, actualFactor, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    setState(() => _transformationController.value = matrix);
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final manuallyVisited = ref.watch(visitedCountriesProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;

    final countryColors = <String, Color>{};
    for (final trip in trips) {
      final code = trip.countryCode;
      if (code == null) continue;
      if (!trip.isVisited) {
        // Upcoming trips take visual priority over past ones to the same country.
        countryColors[code] = _plannedColor;
      } else {
        countryColors.putIfAbsent(code, () => _visitedColor);
      }
    }
    // Trip-linked countries always win: a manual mark only fills in
    // countries with no trip attached, and can't override or hide one.
    final tripCountryCodes = countryColors.keys.toSet();
    for (final code in manuallyVisited) {
      if (!tripCountryCodes.contains(code)) {
        countryColors[code] = _manualColor;
      }
    }
    // "Visited" for the list below means it actually happened: past trips
    // and manual marks, but not upcoming (programado) trips.
    final visitedCountryCodes =
        countryColors.entries
            .where(
              (entry) =>
                  entry.value == _visitedColor || entry.value == _manualColor,
            )
            .map((entry) => entry.key)
            .toList()
          ..sort(
            (a, b) => countryDisplayName(
              a,
              language,
            ).compareTo(countryDisplayName(b, language)),
          );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mapTitle,
                    style: AppTextStyles.display.copyWith(color: onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.mapSubtitle,
                    style: AppTextStyles.body.copyWith(color: secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  _LegendDot(
                    color: _visitedColor,
                    label: l10n.mapLegendVisited,
                  ),
                  _LegendDot(
                    color: _plannedColor,
                    label: l10n.mapLegendPlanned,
                  ),
                  _LegendDot(color: _manualColor, label: l10n.mapLegendManual),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (visitedCountryCodes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _VisitedCountriesToggle(
                  count: visitedCountryCodes.length,
                  expanded: _countriesExpanded,
                  onTap: () =>
                      setState(() => _countriesExpanded = !_countriesExpanded),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Render the map at a *real* size taller/wider than the
                              // viewport (filling the available height, letting width
                              // overflow since the source map is landscape-shaped) and
                              // let InteractiveViewer pan across the actual content —
                              // using BoxFit.cover to crop within a fixed-size box
                              // looked right at rest, but there was nothing left for
                              // InteractiveViewer to pan into, so the cropped regions
                              // (the Americas, etc.) were simply unreachable.
                              final viewportW = constraints.maxWidth;
                              final viewportH = constraints.maxHeight;
                              final contentH = viewportH;
                              var contentW = contentH * _mapAspectRatio;
                              if (contentW < viewportW) contentW = viewportW;

                              if (!_didCenter) {
                                _didCenter = true;
                                final dx = -(contentW - viewportW) / 2;
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted) return;
                                  _transformationController.value =
                                      Matrix4.identity()
                                        ..translateByDouble(dx, 0, 0, 1);
                                });
                              }

                              return InteractiveViewer(
                                key: _viewerKey,
                                constrained: false,
                                transformationController:
                                    _transformationController,
                                minScale: _minScale,
                                maxScale: _maxScale,
                                child: SizedBox(
                                  width: contentW,
                                  height: contentH,
                                  child: SimpleMap(
                                    instructions: SMapWorld.instructions,
                                    defaultColor:
                                        Theme.of(
                                          context,
                                        ).inputDecorationTheme.fillColor ??
                                        AppColors.surfaceLightAlt,
                                    colors: countryColors,
                                    fit: BoxFit.fill,
                                    countryBorder: CountryBorder(
                                      color: onSurface.withValues(alpha: 0.12),
                                      width: 0.6,
                                    ),
                                    callback: (id, name, tapDetails) =>
                                        _onCountryTapped(context, trips, id),
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Column(
                              children: [
                                _ZoomButton(
                                  icon: Icons.add_rounded,
                                  onTap: () => _zoom(1.5),
                                ),
                                const SizedBox(height: 8),
                                _ZoomButton(
                                  icon: Icons.remove_rounded,
                                  onTap: () => _zoom(1 / 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Floats over the map instead of sitting in the Column
                  // above it — if this pushed the map's Expanded region
                  // instead, the resulting layout-constraint change would
                  // shift the already-panned/zoomed map content (the old
                  // bug: expanding this jumped the map up near Russia).
                  if (_countriesExpanded)
                    Positioned(
                      left: 12,
                      right: 12,
                      top: 0,
                      child: _VisitedCountriesFloatingList(
                        countryCodes: visitedCountryCodes,
                        language: language,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCountryTapped(BuildContext context, List<Trip> trips, String id) {
    final matches = trips.where((t) => t.countryCode == id).toList();
    if (matches.isEmpty) {
      // No trip covers this country — tapping just toggles the manual
      // "visited" mark. Countries with a real trip can only be cleared by
      // deleting the trip, so this branch never touches those.
      ref.read(visitedCountriesProvider.notifier).toggle(id);
      return;
    }
    final language = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat(
      'd MMM yyyy',
      Localizations.localeOf(context).toString(),
    );

    showModalBottomSheet(
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
                countryDisplayName(id, language),
                style: AppTextStyles.title.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ...matches.map(
                (trip) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    trip.isVisited
                        ? Icons.check_circle_rounded
                        : Icons.event_rounded,
                    color: trip.isVisited ? _visitedColor : _plannedColor,
                  ),
                  title: Text(trip.destination),
                  subtitle: Text(
                    '${dateFormat.format(trip.startDate)} — ${dateFormat.format(trip.endDate)}',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PackingListScreen(trip: trip),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Just the tappable header row (icon, count, chevron) — always sits in the
/// screen's normal Column flow, at a fixed height regardless of expanded
/// state, so toggling it never resizes (and therefore never shifts) the
/// map below it. The actual list floats over the map instead; see
/// [_VisitedCountriesFloatingList].
class _VisitedCountriesToggle extends StatelessWidget {
  const _VisitedCountriesToggle({
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.flag_rounded, size: 18, color: secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.mapVisitedCountriesCount(count),
                  style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.expand_more_rounded, color: secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The expanded country list, positioned over the map (see the [Positioned]
/// in [_TripsMapScreenState.build]) rather than pushed inline below the
/// toggle — that way it never changes the map's layout constraints.
class _VisitedCountriesFloatingList extends StatelessWidget {
  const _VisitedCountriesFloatingList({
    required this.countryCodes,
    required this.language,
  });

  final List<String> countryCodes;
  final String language;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          itemCount: countryCodes.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: secondary?.withValues(alpha: 0.15)),
          itemBuilder: (context, index) {
            final code = countryCodes[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    countryFlagEmoji(code),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    countryDisplayName(code, language),
                    style: AppTextStyles.body.copyWith(color: onSurface),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
