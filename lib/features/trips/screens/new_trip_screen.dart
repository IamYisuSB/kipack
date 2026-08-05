import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/premium/premium_gate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../packing_list/models/packing_template.dart';
import '../../packing_list/providers/packing_templates_provider.dart';
import '../../packing_list/screens/packing_list_screen.dart';
import '../../packing_list/screens/templates_screen.dart';
import '../../weather/models/geo_suggestion.dart';
import '../../weather/services/weather_service.dart';
import '../models/trip_activity.dart';
import '../models/trip_type.dart';
import '../providers/trips_provider.dart';
import '../services/reminders_service.dart';

class NewTripScreen extends ConsumerStatefulWidget {
  const NewTripScreen({super.key});

  @override
  ConsumerState<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends ConsumerState<NewTripScreen> {
  final _destinationController = TextEditingController();
  final _destinationFocusNode = FocusNode();
  DateTimeRange? _dateRange;
  final Set<TripType> _selectedTypes = {};
  int _peopleCount = 1;
  bool _isSubmitting = false;
  static const _weatherService = WeatherService();

  Timer? _searchDebounce;
  Timer? _pollTimer;
  String _lastQuery = '';
  List<GeoSuggestion> _destinationOptions = [];
  GeoSuggestion? _selectedDestination;
  bool _isSearchingDestinations = false;
  PackingTemplate? _selectedTemplate;
  bool _remindersEnabled = false;
  final Set<TripActivity> _selectedActivities = {};

  @override
  void initState() {
    super.initState();
    // Some OEM keyboards (ColorOS's default one included) buffer typed
    // characters in a "composing" state and only report them to the app
    // once composing ends (space/punctuation/selection change), so
    // TextField.onChanged alone can go silent for the word you're currently
    // typing. Polling the controller directly sidesteps the whole problem:
    // it doesn't matter whether the OS ever fires the change event, we just
    // notice the text is different from what we last processed.
    _pollTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _onDestinationQueryChanged(_destinationController.text);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _pollTimer?.cancel();
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedDestination != null &&
      _dateRange != null &&
      _selectedTypes.isNotEmpty &&
      !_isSubmitting;

  void _onDestinationQueryChanged(String query) {
    if (query == _lastQuery || _selectedDestination != null) return;
    _lastQuery = query;
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() => _destinationOptions = []);
      return;
    }
    final language = Localizations.localeOf(context).languageCode;
    _searchDebounce = Timer(const Duration(milliseconds: 150), () async {
      setState(() => _isSearchingDestinations = true);
      final results = await _weatherService.searchDestinations(
        trimmed,
        language: language,
      );
      if (!mounted) return;
      setState(() {
        _destinationOptions = results;
        _isSearchingDestinations = false;
      });
    });
  }

  void _clearDestination() {
    _searchDebounce?.cancel();
    _destinationController.clear();
    _lastQuery = '';
    setState(() {
      _selectedDestination = null;
      _destinationOptions = [];
    });
  }

  Future<void> _toggleActivity(TripActivity activity, bool isSelected) async {
    if (!isSelected) {
      setState(() => _selectedActivities.remove(activity));
      return;
    }
    final allowed = await requirePremium(
      context,
      ref,
      featureName: AppLocalizations.of(context).newTripActivitiesFeatureName,
    );
    if (!allowed || !mounted) return;
    setState(() => _selectedActivities.add(activity));
  }

  Future<void> _toggleReminders(bool enabled) async {
    if (!enabled) {
      setState(() => _remindersEnabled = false);
      return;
    }
    final allowed = await requirePremium(
      context,
      ref,
      featureName: AppLocalizations.of(context).newTripRemindersFeatureName,
    );
    if (!allowed || !mounted) return;
    await RemindersService.instance.requestPermission();
    if (!mounted) return;
    setState(() => _remindersEnabled = true);
  }

  Future<void> _manageTemplates() async {
    final allowed = await requirePremium(
      context,
      ref,
      featureName: AppLocalizations.of(context).packingListTemplatesFeatureName,
    );
    if (!allowed || !mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TemplatesScreen()));
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDateRange: _dateRange,
    );
    if (range != null) setState(() => _dateRange = range);
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    try {
      final destination = _selectedDestination!;
      final weather = await _weatherService.fetchWeatherForLocation(
        location: destination.location,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
      );

      if (!mounted) return;
      final trip = ref
          .read(tripsProvider.notifier)
          .addTrip(
            destination: destination.name,
            startDate: _dateRange!.start,
            endDate: _dateRange!.end,
            types: _selectedTypes.toList(),
            peopleCount: _peopleCount,
            activities: _selectedActivities.toList(),
            weather: weather,
            countryCode: destination.countryCode,
          );

      if (_remindersEnabled) {
        // A side feature on top of trip creation — if scheduling fails for
        // any reason (permission hiccup, plugin error) that must never
        // block getting to the packing list for a trip that's already
        // been saved.
        try {
          await RemindersService.instance.scheduleTripReminders(trip);
        } catch (error) {
          debugPrint('No se pudieron programar los recordatorios: $error');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PackingListScreen(
            trip: trip,
            templateItemsToApply: _selectedTemplate?.items,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    // Inverts by brightness (see AppColors.chipSelectedForeground): lime
    // text on a dark-green fill in light mode, dark text on a lime fill in
    // dark mode.
    final onSelectedChip = AppColors.chipSelectedForeground(context);
    final dateFormat = DateFormat(
      'd MMM yyyy',
      Localizations.localeOf(context).toString(),
    );
    final templates = ref.watch(packingTemplatesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newTripTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              l10n.newTripDestinationLabel,
              style: AppTextStyles.subtitle.copyWith(color: onSurface),
            ),
            const SizedBox(height: 10),
            // Once a destination is picked, RawAutocomplete (and the
            // TextField/controller wiring inside it) is removed from the
            // tree entirely and swapped for a plain, static card. Locking
            // the same TextField in place (e.g. with AbsorbPointer) wasn't
            // enough to stop the dropdown from reappearing after picking
            // dates, because RawAutocomplete re-syncs its controller/focus
            // internally on rebuild — not from a user touch, so nothing
            // that only blocks pointer events can prevent it. Unmounting it
            // completely is the only way to guarantee it can't fire again.
            _selectedDestination == null
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return RawAutocomplete<GeoSuggestion>(
                        textEditingController: _destinationController,
                        focusNode: _destinationFocusNode,
                        optionsBuilder: (_) => _destinationOptions,
                        displayStringForOption: (option) => option.label,
                        onSelected: (option) {
                          _searchDebounce?.cancel();
                          setState(() {
                            _selectedDestination = option;
                            _destinationOptions = [];
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                onChanged: _onDestinationQueryChanged,
                                decoration: InputDecoration(
                                  hintText: l10n.newTripDestinationHint,
                                  prefixIcon: const Icon(Icons.place_outlined),
                                  suffixIcon: _isSearchingDestinations
                                      ? const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).cardTheme.color,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 260,
                                  ),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        leading: Icon(
                                          Icons.location_on_outlined,
                                          color: secondary,
                                        ),
                                        title: Text(
                                          option.label,
                                          style: AppTextStyles.body.copyWith(
                                            color: onSurface,
                                          ),
                                        ),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDestination!.label,
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: onSurface,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _clearDestination,
                          child: Text(l10n.commonChange),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 28),
            Text(
              l10n.newTripDatesLabel,
              style: AppTextStyles.subtitle.copyWith(color: onSurface),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _dateRange == null
                          ? l10n.newTripSelectDates
                          : '${dateFormat.format(_dateRange!.start)}  →  ${dateFormat.format(_dateRange!.end)}',
                      style: AppTextStyles.body.copyWith(
                        color: _dateRange == null ? secondary : onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.newTripTypeLabel,
              style: AppTextStyles.subtitle.copyWith(color: onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.newTripMultiSelectHint,
              style: AppTextStyles.caption.copyWith(color: secondary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TripType.values.map((type) {
                final selected = _selectedTypes.contains(type);
                return FilterChip(
                  label: Text(
                    type.displayLabel(context),
                    style: selected ? TextStyle(color: onSelectedChip) : null,
                  ),
                  avatar: Icon(
                    type.icon,
                    size: 18,
                    color: selected ? onSelectedChip : secondary,
                  ),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (isSelected) => setState(() {
                    if (isSelected) {
                      _selectedTypes.add(type);
                    } else if (_selectedTypes.length > 1) {
                      // Keep at least one type selected.
                      _selectedTypes.remove(type);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.newTripActivitiesLabel,
              style: AppTextStyles.subtitle.copyWith(color: onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.newTripActivitiesHint,
              style: AppTextStyles.caption.copyWith(color: secondary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TripActivity.values.map((activity) {
                final selected = _selectedActivities.contains(activity);
                return FilterChip(
                  label: Text(
                    activity.displayLabel(context),
                    style: selected ? TextStyle(color: onSelectedChip) : null,
                  ),
                  avatar: Icon(
                    activity.icon,
                    size: 18,
                    color: selected ? onSelectedChip : secondary,
                  ),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (isSelected) =>
                      _toggleActivity(activity, isSelected),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text(
                  l10n.newTripTemplateLabel,
                  style: AppTextStyles.subtitle.copyWith(color: onSurface),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _manageTemplates,
                  child: Text(l10n.commonManage),
                ),
              ],
            ),
            if (templates.isEmpty)
              Text(
                l10n.newTripTemplateEmptyHint,
                style: AppTextStyles.caption.copyWith(color: secondary),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: templates.map((template) {
                  final selected = _selectedTemplate?.id == template.id;
                  return FilterChip(
                    label: Text(
                      template.name,
                      style: selected ? TextStyle(color: onSelectedChip) : null,
                    ),
                    avatar: Icon(
                      Icons.bookmark_rounded,
                      size: 18,
                      color: selected ? onSelectedChip : secondary,
                    ),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (isSelected) => setState(
                      () => _selectedTemplate = isSelected ? template : null,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.newTripRemindersFeatureName,
                  style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
                ),
                subtitle: Text(
                  l10n.newTripRemindersSubtitle,
                  style: AppTextStyles.caption.copyWith(color: secondary),
                ),
                value: _remindersEnabled,
                onChanged: _toggleReminders,
                activeThumbColor: AppColors.chipSelectedBackground(context),
                activeTrackColor: AppColors.chipSelectedBackground(
                  context,
                ).withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.newTripPeopleLabel,
              style: AppTextStyles.subtitle.copyWith(color: onSurface),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _peopleCount > 1
                        ? () => setState(() => _peopleCount--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Expanded(
                    child: Text(
                      l10n.newTripPeopleCount(_peopleCount),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _peopleCount < 12
                        ? () => setState(() => _peopleCount++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSubmit ? _submit : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.backgroundLight,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _isSubmitting
                      ? l10n.newTripCheckingWeather
                      : l10n.newTripGenerateButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
