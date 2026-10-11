import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_store.dart';
import '../../trips/models/trip.dart';
import '../../trips/services/reminders_service.dart';
import '../models/packing_item.dart';
import '../models/packing_template.dart';
import '../services/ai_packing_list_service.dart';
import '../services/packing_list_generator.dart';

class PackingListNotifier extends StateNotifier<List<PackingItem>> {
  PackingListNotifier(this.tripId) : super(const []) {
    _ready = _load();
  }

  final String tripId;
  static const _aiService = AiPackingListService();
  static const _fallbackGenerator = PackingListGenerator();
  static const _uuid = Uuid();

  late final Future<void> _ready;
  bool _loaded = false;

  String get _storageKey => 'packing_$tripId';

  Future<void> _load() async {
    final raw = await LocalStore.instance.readList(_storageKey);
    if (raw.isNotEmpty) {
      state = raw.map(PackingItem.fromJson).toList();
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    await LocalStore.instance.writeList(
      _storageKey,
      state.map((i) => i.toJson()).toList(),
    );
  }

  /// Waits for any saved list to load, then generates a fresh one only if
  /// this trip doesn't already have one saved.
  Future<void> ensureGenerated(Trip trip, {String language = 'es'}) async {
    await _ready;
    if (!_loaded) {
      await generateFor(trip, language: language);
    }
  }

  Future<void> generateFor(Trip trip, {String language = 'es'}) async {
    List<PackingItem> items;
    try {
      items = await _aiService.generate(trip, language: language);
    } catch (error) {
      debugPrint(
        'AI packing list generation failed, using rule-based fallback: $error',
      );
      items = await _fallbackGenerator.generate(trip);
    }
    state = items;
    _loaded = true;
    await _persist();
  }

  void seedItems(List<PackingItem> items) {
    state = items;
    _loaded = true;
    _persist();
  }

  /// Swaps the whole list — used by the AI chat, which rewrites the entire
  /// list at once rather than making one-off item edits.
  void replaceAll(List<PackingItem> items) {
    state = items;
    _persist();
  }

  void togglePacked(String itemId) {
    state = [
      for (final item in state)
        if (item.id == itemId) item.copyWith(isPacked: !item.isPacked) else item,
    ];
    _persist();
    // Stop nagging once the list is fully checked off — no point in a "3
    // days left" reminder for a bag that's already packed.
    if (state.isNotEmpty && state.every((i) => i.isPacked)) {
      RemindersService.instance.cancelTripReminders(tripId);
    }
  }

  void addItem(PackingItem item) {
    state = [...state, item];
    _persist();
  }

  void removeItem(String itemId) {
    state = state.where((i) => i.id != itemId).toList();
    _persist();
  }

  void assignSuitcase(String itemId, String? suitcaseId) {
    state = [
      for (final item in state)
        if (item.id == itemId) item.copyWith(suitcaseId: suitcaseId) else item,
    ];
    _persist();
  }

  /// Unassigns any items pointing at a suitcase that's about to be deleted.
  void unassignSuitcase(String suitcaseId) {
    state = [
      for (final item in state)
        if (item.suitcaseId == suitcaseId)
          item.copyWith(suitcaseId: null)
        else
          item,
    ];
    _persist();
  }

  /// Adds a template's items to the current list, skipping any whose name
  /// already exists here (case-insensitive) so re-applying a template
  /// doesn't pile up duplicates.
  int applyTemplate(List<TemplateItem> templateItems) {
    final existingNames = state.map((i) => i.name.trim().toLowerCase()).toSet();
    final newItems = <PackingItem>[];
    for (final templateItem in templateItems) {
      if (!existingNames.add(templateItem.name.trim().toLowerCase())) continue;
      newItems.add(
        PackingItem(
          id: _uuid.v4(),
          name: templateItem.name,
          category: templateItem.category,
          quantity: templateItem.quantity,
        ),
      );
    }
    if (newItems.isEmpty) return 0;
    state = [...state, ...newItems];
    _persist();
    return newItems.length;
  }
}

final packingListProvider =
    StateNotifierProvider.family<
      PackingListNotifier,
      List<PackingItem>,
      String
    >((ref, tripId) {
      return PackingListNotifier(tripId);
    });
