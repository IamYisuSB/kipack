import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/packing_category.dart';
import '../models/packing_template.dart';
import '../providers/packing_templates_provider.dart';

/// Add/remove items on a single template. Watches the provider by id
/// (rather than taking the [PackingTemplate] itself) so edits show up live
/// and the screen degrades gracefully if the template gets deleted from
/// under it (e.g. back on the list screen).
class TemplateDetailScreen extends ConsumerWidget {
  const TemplateDetailScreen({super.key, required this.templateId});

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(packingTemplatesProvider);
    PackingTemplate? template;
    for (final t in templates) {
      if (t.id == templateId) {
        template = t;
        break;
      }
    }

    if (template == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    // A fresh, single-assignment local so the non-null narrowing survives
    // into the closures below (ListView's itemBuilder, IconButton.onPressed)
    // — Dart doesn't carry a null-check's promotion into nested closures.
    final resolved = template;

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      appBar: AppBar(title: Text(resolved.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: resolved.items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Añade los artículos que quieres que estén siempre en "${resolved.name}".',
                    style: AppTextStyles.body.copyWith(color: secondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                itemCount: resolved.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = resolved.items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      item.category.icon,
                      color: item.category.color,
                    ),
                    title: Text(
                      item.name,
                      style: AppTextStyles.body.copyWith(color: onSurface),
                    ),
                    subtitle: Text(
                      '${item.category.label} · x${item.quantity}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () => ref
                          .read(packingTemplatesProvider.notifier)
                          .removeItem(resolved.id, item.id),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _addItem(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    var category = PackingCategory.misc;
    var quantity = 1;
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
                      'Añadir artículo',
                      style: AppTextStyles.title.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Nombre del artículo',
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
                            c.label,
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Cantidad',
                          style: AppTextStyles.body.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: quantity > 1
                              ? () => setSheetState(() => quantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                        ),
                        Text(
                          '$quantity',
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setSheetState(() => quantity++),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          ref
                              .read(packingTemplatesProvider.notifier)
                              .addItem(
                                templateId,
                                name: name,
                                category: category,
                                quantity: quantity,
                              );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Añadir'),
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
}
