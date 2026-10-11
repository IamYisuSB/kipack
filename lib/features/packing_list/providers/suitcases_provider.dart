import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_store.dart';
import '../models/suitcase.dart';

class SuitcasesNotifier extends StateNotifier<List<Suitcase>> {
  SuitcasesNotifier(this.tripId) : super(const []) {
    _ready = _load();
  }

  final String tripId;
  static const _uuid = Uuid();

  late final Future<void> _ready;
  Future<void> get ready => _ready;

  String get _storageKey => 'suitcases_$tripId';

  Future<void> _load() async {
    final raw = await LocalStore.instance.readList(_storageKey);
    state = raw.map(Suitcase.fromJson).toList();
  }

  Future<void> _persist() async {
    await LocalStore.instance.writeList(
      _storageKey,
      state.map((s) => s.toJson()).toList(),
    );
  }

  Suitcase addSuitcase(String? name) {
    final suitcase = Suitcase(
      id: _uuid.v4(),
      name: name?.trim().isNotEmpty == true
          ? name!
          : 'Maleta ${state.length + 1}',
    );
    state = [...state, suitcase];
    _persist();
    return suitcase;
  }

  void removeSuitcase(String id) {
    state = state.where((s) => s.id != id).toList();
    _persist();
  }

  void seedSuitcases(List<Suitcase> suitcases) {
    state = suitcases;
    _persist();
  }
}

final suitcasesProvider =
    StateNotifierProvider.family<SuitcasesNotifier, List<Suitcase>, String>((
      ref,
      tripId,
    ) {
      return SuitcasesNotifier(tripId);
    });
