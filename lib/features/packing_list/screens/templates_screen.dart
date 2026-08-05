import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/packing_template.dart';
import '../providers/packing_templates_provider.dart';
import 'template_detail_screen.dart';

/// Manage screen: create, open, or delete templates. Building a template's
/// items happens in [TemplateDetailScreen] — this screen is just the list.
class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(packingTemplatesProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      appBar: AppBar(title: const Text('Plantillas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTemplate(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva plantilla'),
      ),
      body: SafeArea(
        child: templates.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: AppColors.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_add_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Aún no tienes plantillas',
                        style: AppTextStyles.title.copyWith(color: onSurface),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea una plantilla con lo que siempre llevas a un tipo de viaje (p. ej. "Negocios": '
                        'portátil, cargador, tarjetas) y aplícala a cualquier viaje nuevo.',
                        style: AppTextStyles.body.copyWith(color: secondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                itemCount: templates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return Material(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TemplateDetailScreen(templateId: template.id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bookmark_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.name,
                                    style: AppTextStyles.bodyStrong.copyWith(
                                      color: onSurface,
                                    ),
                                  ),
                                  Text(
                                    template.items.isEmpty
                                        ? 'Sin artículos todavía'
                                        : '${template.items.length} '
                                              '${template.items.length == 1 ? "artículo" : "artículos"}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                              ),
                              onPressed: () =>
                                  _confirmDelete(context, ref, template),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _createTemplate(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva plantilla'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ej. Negocios, Playa'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;

    final template = ref
        .read(packingTemplatesProvider.notifier)
        .createTemplate(name);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TemplateDetailScreen(templateId: template.id),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PackingTemplate template,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar plantilla'),
        content: Text(
          '¿Seguro que quieres eliminar "${template.name}"? Esta acción no se puede deshacer.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(packingTemplatesProvider.notifier).deleteTemplate(template.id);
    }
  }
}
