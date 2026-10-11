import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/ads/ads_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../trips/models/trip.dart';
import '../../trips/widgets/weather_card.dart';
import '../../trips/widgets/weather_detail_sheet.dart';
import '../models/packing_category.dart';
import '../models/packing_item.dart';
import '../models/packing_template.dart';
import '../models/suitcase.dart';
import '../providers/packing_list_provider.dart';
import '../providers/packing_templates_provider.dart';
import '../providers/suitcases_provider.dart';
import '../services/packing_list_pdf_service.dart';
import '../widgets/category_section.dart';
import '../../../l10n/app_localizations.dart';
import 'packing_chat_sheet.dart';

enum _ShareMenuAction { template, exportPdf }

class PackingListScreen extends ConsumerStatefulWidget {
  const PackingListScreen({
    super.key,
    required this.trip,
    this.templateItemsToApply,
    this.isNewTrip = false,
  });

  final Trip trip;

  /// Items from a template picked at trip-creation time, merged into the
  /// list right after it's generated (once, not on every reopen).
  final List<TemplateItem>? templateItemsToApply;

  /// True right after creating the trip — the list is being generated, so
  /// that wait is when an interstitial ad is shown.
  final bool isNewTrip;

  @override
  ConsumerState<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends ConsumerState<PackingListScreen> {
  String? _suitcaseFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final language = Localizations.localeOf(context).languageCode;
      final generation = ref
          .read(packingListProvider(widget.trip.id).notifier)
          .ensureGenerated(widget.trip, language: language);
      if (widget.isNewTrip) adsService.showInterstitial();
      await generation;
      if (!mounted) return;
      final templateItems = widget.templateItemsToApply;
      if (templateItems != null && templateItems.isNotEmpty) {
        ref
            .read(packingListProvider(widget.trip.id).notifier)
            .applyTemplate(templateItems);
      }
    });
  }

  void _addItem() {
    final controller = TextEditingController();
    var category = PackingCategory.misc;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).packingListAddItemTitle,
                      style: AppTextStyles.title.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        ).packingListItemNameHint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PackingCategory.values.map((c) {
                        final selected = c == category;
                        final selectedFg = AppColors.chipSelectedForeground(
                          context,
                        );
                        return ChoiceChip(
                          label: Text(
                            c.displayLabel(context),
                            style: selected
                                ? TextStyle(color: selectedFg)
                                : null,
                          ),
                          avatar: Icon(
                            c.icon,
                            size: 16,
                            color: selected ? selectedFg : null,
                          ),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (_) => setSheetState(() => category = c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          ref
                              .read(
                                packingListProvider(widget.trip.id).notifier,
                              )
                              .addItem(
                                PackingItem(
                                  id: DateTime.now().microsecondsSinceEpoch
                                      .toString(),
                                  name: name,
                                  category: category,
                                  suitcaseId: _suitcaseFilter,
                                ),
                              );
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context).commonAdd),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openAiChat() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PackingChatSheet(trip: widget.trip),
    );
  }

  Future<void> _exportPdf() async {
    final items = ref.read(packingListProvider(widget.trip.id));
    final bytes = await packingListPdfService.build(
      trip: widget.trip,
      items: items,
    );
    if (!mounted) return;
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'equipaje-${widget.trip.destination}.pdf',
    );
  }

  Future<void> _openWeatherDetail() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeatherDetailSheet(
        weather: widget.trip.weather!,
        destination: widget.trip.destination,
      ),
    );
  }

  Future<void> _applyTemplate() async {
    final selected = await showModalBottomSheet<PackingTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TemplatePickerSheet(),
    );
    if (selected == null || !mounted) return;

    final added = ref
        .read(packingListProvider(widget.trip.id).notifier)
        .applyTemplate(selected.items);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added == 0
              ? l10n.templateApplyAllAlreadyIn(selected.name)
              : l10n.templateApplyAddedCount(added, selected.name),
        ),
      ),
    );
  }

  Future<void> _addSuitcase() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.packingListNewSuitcaseTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.packingListNewSuitcaseHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.commonCreate),
          ),
        ],
      ),
    );
    if (name == null) return;
    final suitcase = ref
        .read(suitcasesProvider(widget.trip.id).notifier)
        .addSuitcase(name);
    setState(() => _suitcaseFilter = suitcase.id);
  }

  Future<void> _confirmDeleteSuitcase(Suitcase suitcase) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.packingListDeleteSuitcaseTitle),
        content: Text(l10n.packingListDeleteSuitcaseBody(suitcase.name)),
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
    if (confirmed != true) return;
    ref
        .read(packingListProvider(widget.trip.id).notifier)
        .unassignSuitcase(suitcase.id);
    ref
        .read(suitcasesProvider(widget.trip.id).notifier)
        .removeSuitcase(suitcase.id);
    if (_suitcaseFilter == suitcase.id) setState(() => _suitcaseFilter = null);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(packingListProvider(widget.trip.id));
    final suitcases = ref.watch(suitcasesProvider(widget.trip.id));
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final selectedChipFg = AppColors.chipSelectedForeground(context);
    final dateFormat = DateFormat(
      'd MMM',
      Localizations.localeOf(context).toString(),
    );

    final packed = items.where((i) => i.isPacked).length;
    final progress = items.isEmpty ? 0.0 : packed / items.length;

    final visibleItems = _suitcaseFilter == null
        ? items
        : items.where((i) => i.suitcaseId == _suitcaseFilter).toList();

    final byCategory = <PackingCategory, List<PackingItem>>{};
    for (final item in visibleItems) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    final menuL10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.destination),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: menuL10n.packingListAiChatTooltip,
            onPressed: _openAiChat,
          ),
          PopupMenuButton<_ShareMenuAction>(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: menuL10n.packingListShareTooltip,
            onSelected: (action) {
              switch (action) {
                case _ShareMenuAction.template:
                  _applyTemplate();
                case _ShareMenuAction.exportPdf:
                  _exportPdf();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _ShareMenuAction.template,
                child: Row(
                  children: [
                    const Icon(Icons.playlist_add_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(menuL10n.shareMenuApplyTemplate),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _ShareMenuAction.exportPdf,
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(menuL10n.shareMenuExportPdf),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const _GeneratingListIndicator()
            : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  children: [
                    Text(
                      AppLocalizations.of(context).tripSummaryLine(
                        '${dateFormat.format(widget.trip.startDate)} — ${dateFormat.format(widget.trip.endDate)}',
                        widget.trip.types
                            .map((t) => t.displayLabel(context))
                            .join(", "),
                        widget.trip.peopleCount,
                      ),
                      style: AppTextStyles.body.copyWith(color: secondary),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Theme.of(
                          context,
                        ).inputDecorationTheme.fillColor,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).packingListProgressLine(packed, items.length),
                      style: AppTextStyles.caption.copyWith(color: secondary),
                    ),
                    if (widget.trip.weather != null) ...[
                      const SizedBox(height: 16),
                      WeatherCard(
                        weather: widget.trip.weather!,
                        destination: widget.trip.destination,
                        onTap: widget.trip.weather!.hasDailyBreakdown
                            ? _openWeatherDetail
                            : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                AppLocalizations.of(context).commonAll,
                                style: _suitcaseFilter == null
                                    ? TextStyle(color: selectedChipFg)
                                    : null,
                              ),
                              selected: _suitcaseFilter == null,
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _suitcaseFilter = null),
                            ),
                          ),
                          for (final s in suitcases)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onLongPress: () => _confirmDeleteSuitcase(s),
                                child: ChoiceChip(
                                  avatar: Icon(
                                    Icons.luggage_rounded,
                                    size: 16,
                                    color: _suitcaseFilter == s.id
                                        ? selectedChipFg
                                        : null,
                                  ),
                                  label: Text(
                                    s.name,
                                    style: _suitcaseFilter == s.id
                                        ? TextStyle(color: selectedChipFg)
                                        : null,
                                  ),
                                  selected: _suitcaseFilter == s.id,
                                  showCheckmark: false,
                                  onSelected: (_) =>
                                      setState(() => _suitcaseFilter = s.id),
                                ),
                              ),
                            ),
                          ActionChip(
                            avatar: const Icon(Icons.add_rounded, size: 16),
                            label: Text(
                              AppLocalizations.of(
                                context,
                              ).packingListNewSuitcaseTitle,
                            ),
                            onPressed: _addSuitcase,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (visibleItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          AppLocalizations.of(context).packingListEmptySuitcase,
                          style: AppTextStyles.body.copyWith(color: secondary),
                        ),
                      ),
                    for (final category in PackingCategory.values)
                      if (byCategory[category] case final items?)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CategorySection(
                            category: category,
                            items: items,
                            suitcases: suitcases,
                            onToggle: (id) => ref
                                .read(
                                  packingListProvider(widget.trip.id).notifier,
                                )
                                .togglePacked(id),
                            onRemove: (id) => ref
                                .read(
                                  packingListProvider(widget.trip.id).notifier,
                                )
                                .removeItem(id),
                            onAssignSuitcase: (itemId, suitcaseId) => ref
                                .read(
                                  packingListProvider(widget.trip.id).notifier,
                                )
                                .assignSuitcase(itemId, suitcaseId),
                          ),
                        ),
                  ],
                ),
      ),
    );
  }
}

class _TemplatePickerSheet extends ConsumerWidget {
  const _TemplatePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(packingTemplatesProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

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
            l10n.shareMenuApplyTemplate,
            style: AppTextStyles.title.copyWith(color: onSurface),
          ),
          const SizedBox(height: 8),
          if (templates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.templatesEmptyHint,
                style: AppTextStyles.body.copyWith(color: secondary),
              ),
            )
          else
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: templates.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.bookmark_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(template.name),
                      subtitle: Text(
                        l10n.templateItemsCount(template.items.length),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.templateDeleteTitle),
                              content: Text(
                                l10n.templateDeleteConfirm(template.name),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(l10n.commonCancel),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    l10n.commonDelete,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            ref
                                .read(packingTemplatesProvider.notifier)
                                .deleteTemplate(template.id);
                          }
                        },
                      ),
                      onTap: () => Navigator.of(context).pop(template),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Replaces a plain spinner while the AI list is being generated with
/// rotating "thinking" copy — cycles through a few phrases (if it takes a
/// while) with an animated trailing ellipsis, so a wait of several seconds
/// reads as active progress instead of a frozen wheel.
class _GeneratingListIndicator extends StatefulWidget {
  const _GeneratingListIndicator();

  @override
  State<_GeneratingListIndicator> createState() =>
      _GeneratingListIndicatorState();
}

class _GeneratingListIndicatorState extends State<_GeneratingListIndicator> {
  Timer? _dotsTimer;
  Timer? _phraseTimer;
  int _dotCount = 1;
  int _phraseIndex = 0;

  @override
  void initState() {
    super.initState();
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() => _dotCount = _dotCount % 3 + 1);
    });
    _phraseTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _phraseIndex = (_phraseIndex + 1) % _phraseCount);
    });
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    _phraseTimer?.cancel();
    super.dispose();
  }

  static const _phraseCount = 5;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);
    final phrases = [
      l10n.aiThinking1,
      l10n.aiThinking2,
      l10n.aiThinking3,
      l10n.aiThinking4,
      l10n.aiThinking5,
    ];
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '${phrases[_phraseIndex]}${'.' * _dotCount}',
              style: AppTextStyles.title.copyWith(color: onSurface),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          left: 32,
          right: 32,
          bottom: 32,
          child: Text(
            l10n.aiGeneratingPleaseWait,
            style: AppTextStyles.caption.copyWith(color: secondary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
