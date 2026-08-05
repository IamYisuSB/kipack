import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_store.dart';
import '../models/packing_category.dart';
import '../models/packing_template.dart';

const _storageKey = 'packing_templates';

/// Reusable, hand-built packing checklists (e.g. "Negocios", "Playa") the
/// user curates item by item and can apply to any new trip. Local-only for
/// now, same as trips — swappable for a Supabase-backed store later.
class PackingTemplatesNotifier extends StateNotifier<List<PackingTemplate>> {
  PackingTemplatesNotifier() : super(const []) {
    _load();
  }

  static const _uuid = Uuid();

  Future<void> _load() async {
    final raw = await LocalStore.instance.readList(_storageKey);
    state = raw.map(PackingTemplate.fromJson).toList();
  }

  Future<void> _persist() async {
    await LocalStore.instance.writeList(
      _storageKey,
      state.map((t) => t.toJson()).toList(),
    );
  }

  PackingTemplate createTemplate(String name) {
    final template = PackingTemplate(
      id: _uuid.v4(),
      name: name,
      items: const [],
    );
    state = [template, ...state];
    _persist();
    return template;
  }

  void deleteTemplate(String id) {
    state = state.where((t) => t.id != id).toList();
    _persist();
  }

  void addItem(
    String templateId, {
    required String name,
    required PackingCategory category,
    int quantity = 1,
  }) {
    state = [
      for (final template in state)
        if (template.id == templateId)
          template.copyWith(
            items: [
              ...template.items,
              TemplateItem(
                id: _uuid.v4(),
                name: name,
                category: category,
                quantity: quantity,
              ),
            ],
          )
        else
          template,
    ];
    _persist();
  }

  void removeItem(String templateId, String itemId) {
    state = [
      for (final template in state)
        if (template.id == templateId)
          template.copyWith(
            items: template.items.where((i) => i.id != itemId).toList(),
          )
        else
          template,
    ];
    _persist();
  }
}

final packingTemplatesProvider =
    StateNotifierProvider<PackingTemplatesNotifier, List<PackingTemplate>>((
      ref,
    ) {
      return PackingTemplatesNotifier();
    });
