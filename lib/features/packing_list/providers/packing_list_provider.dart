import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/sync/realtime_table_sync.dart';
import '../../../core/sync/sync_context.dart';
import '../../trips/models/trip.dart';
import '../../trips/services/reminders_service.dart';
import '../models/packing_category.dart';
import '../models/packing_item.dart';
import '../models/packing_template.dart';
import '../services/ai_packing_list_service.dart';
import '../services/packing_list_generator.dart';

class PackingListNotifier extends StateNotifier<List<PackingItem>> {
  PackingListNotifier(this.tripId, this.ref) : super(const []) {
    _ready = _load();
  }

  final String tripId;
  final Ref ref;
  static const _aiService = AiPackingListService();
  static const _fallbackGenerator = PackingListGenerator();
  static const _uuid = Uuid();
  RealtimeTableSync? _realtimeSync;

  late final Future<void> _ready;
  bool _loaded = false;

  String get _storageKey => 'packing_$tripId';

  Future<void> _load() async {
    final raw = await LocalStore.instance.readList(_storageKey);
    if (raw.isNotEmpty) {
      state = raw.map(PackingItem.fromJson).toList();
      _loaded = true;
    }
    if (canSync(ref)) {
      await _syncFromRemote();
      _subscribeRealtime();
    }
  }

  void _subscribeRealtime() {
    _realtimeSync?.dispose();
    _realtimeSync = RealtimeTableSync(
      channelName: 'packing_items_$tripId',
      table: 'packing_items',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'trip_id',
        value: tripId,
      ),
      onChange: _syncFromRemote,
    );
  }

  @override
  void dispose() {
    _realtimeSync?.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    await LocalStore.instance.writeList(
      _storageKey,
      state.map((i) => i.toJson()).toList(),
    );
  }

  Map<String, dynamic> _itemToRow(PackingItem item) => {
    'id': item.id,
    'trip_id': tripId,
    'suitcase_id': item.suitcaseId,
    'assigned_user_id': item.assignedUserId,
    'name': item.name,
    'category': item.category.name,
    'quantity': item.quantity,
    'is_packed': item.isPacked,
  };

  PackingItem _rowToItem(Map<String, dynamic> row) => PackingItem(
    id: row['id'] as String,
    name: row['name'] as String,
    category: PackingCategory.values.byName(row['category'] as String),
    quantity: row['quantity'] as int,
    isPacked: row['is_packed'] as bool,
    suitcaseId: row['suitcase_id'] as String?,
    assignedUserId: row['assigned_user_id'] as String?,
  );

  Future<void> _syncFromRemote() async {
    try {
      final rows = await Supabase.instance.client
          .from('packing_items')
          .select()
          .eq('trip_id', tripId);
      final remoteItems = rows.map(_rowToItem).toList();
      if (remoteItems.isEmpty) {
        for (final item in state) {
          await _pushItem(item);
        }
        return;
      }
      state = remoteItems;
      _loaded = true;
      await _persist();
    } catch (error) {
      debugPrint('No se pudo sincronizar la lista de equipaje: $error');
    }
  }

  /// Pulls the latest items from Supabase — used by pull-to-refresh so a
  /// collaborator's changes show up without leaving/reopening the screen.
  /// No-op for guest/free mode (nothing to pull).
  Future<void> refresh() async {
    if (canSync(ref)) await _syncFromRemote();
  }

  Future<void> _pushItem(PackingItem item) async {
    try {
      await Supabase.instance.client
          .from('packing_items')
          .upsert(_itemToRow(item));
    } catch (error) {
      debugPrint('No se pudo sincronizar el artículo: $error');
    }
  }

  Future<void> _pushAll(List<PackingItem> items) async {
    for (final item in items) {
      await _pushItem(item);
    }
  }

  Future<void> _deleteRemoteItem(String id) async {
    try {
      await Supabase.instance.client
          .from('packing_items')
          .delete()
          .eq('id', id);
    } catch (error) {
      debugPrint('No se pudo borrar el artículo remoto: $error');
    }
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
    if (canSync(ref)) await _pushAll(items);
  }

  void seedItems(List<PackingItem> items) {
    state = items;
    _loaded = true;
    _persist();
    if (canSync(ref)) _pushAll(items);
  }

  /// Swaps the whole list — used by the AI chat, which rewrites the entire
  /// list at once rather than making one-off item edits.
  void replaceAll(List<PackingItem> items) {
    state = items;
    _persist();
    if (canSync(ref)) _pushAll(items);
  }

  /// Toggling ON auto-assigns the item to [userId] (whoever actually packed
  /// it) regardless of any prior manual assignment — the physical act of
  /// packing overrides a pre-plan. Toggling OFF clears the assignment,
  /// freeing the item back up. [PackingItemTile] is what stops anyone
  /// other than the assignee from toggling OFF a packed+assigned item in
  /// the first place — this method itself doesn't re-check that.
  void togglePacked(String itemId, {String? userId}) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          item.copyWith(
            isPacked: !item.isPacked,
            assignedUserId: !item.isPacked ? userId : null,
          )
        else
          item,
    ];
    _persist();
    if (canSync(ref)) {
      final updated = state.firstWhere((i) => i.id == itemId);
      _pushItem(updated);
    }
    // Stop nagging once the list is fully checked off — no point in a "3
    // days left" reminder for a bag that's already packed.
    if (state.isNotEmpty && state.every((i) => i.isPacked)) {
      RemindersService.instance.cancelTripReminders(tripId);
    }
  }

  void addItem(PackingItem item) {
    state = [...state, item];
    _persist();
    if (canSync(ref)) _pushItem(item);
  }

  void removeItem(String itemId) {
    state = state.where((i) => i.id != itemId).toList();
    _persist();
    if (canSync(ref)) _deleteRemoteItem(itemId);
  }

  void assignSuitcase(String itemId, String? suitcaseId) {
    state = [
      for (final item in state)
        if (item.id == itemId) item.copyWith(suitcaseId: suitcaseId) else item,
    ];
    _persist();
    if (canSync(ref)) {
      final updated = state.firstWhere((i) => i.id == itemId);
      _pushItem(updated);
    }
  }

  /// "Cada acompañante marca lo suyo" — assign an item to a specific
  /// collaborator (or `null` to unassign). Only meaningful for shared
  /// trips; harmless no-op otherwise.
  void assignPerson(String itemId, String? userId) {
    state = [
      for (final item in state)
        if (item.id == itemId) item.copyWith(assignedUserId: userId) else item,
    ];
    _persist();
    if (canSync(ref)) {
      final updated = state.firstWhere((i) => i.id == itemId);
      _pushItem(updated);
    }
  }

  /// Unassigns any items pointing at a suitcase that's about to be deleted.
  void unassignSuitcase(String suitcaseId) {
    final affectedIds = state
        .where((i) => i.suitcaseId == suitcaseId)
        .map((i) => i.id)
        .toSet();
    state = [
      for (final item in state)
        if (item.suitcaseId == suitcaseId)
          item.copyWith(suitcaseId: null)
        else
          item,
    ];
    _persist();
    if (canSync(ref))
      _pushAll(state.where((i) => affectedIds.contains(i.id)).toList());
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
    if (canSync(ref)) _pushAll(newItems);
    return newItems.length;
  }
}

final packingListProvider =
    StateNotifierProvider.family<
      PackingListNotifier,
      List<PackingItem>,
      String
    >((ref, tripId) {
      return PackingListNotifier(tripId, ref);
    });
