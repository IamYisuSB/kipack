import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../trips/models/trip.dart';
import '../providers/packing_chat_provider.dart';
import '../providers/packing_list_provider.dart';
import '../services/ai_packing_list_service.dart';

/// Lets the user ask the AI, in free text, to adjust the already-generated
/// packing list — "no llevo mucho espacio, optimiza la maleta", "añade
/// cosas para hacer submarinismo" — rather than editing items by hand.
class PackingChatSheet extends ConsumerStatefulWidget {
  const PackingChatSheet({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<PackingChatSheet> createState() => _PackingChatSheetState();
}

class _PackingChatSheetState extends ConsumerState<PackingChatSheet> {
  static const _service = AiPackingListService();

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;
    _controller.clear();

    final chat = ref.read(packingChatProvider(widget.trip.id).notifier);
    chat.addUser(text);
    setState(() => _isSending = true);
    _scrollToBottom();

    try {
      final currentItems = ref.read(packingListProvider(widget.trip.id));
      final language = Localizations.localeOf(context).languageCode;
      final result = await _service.refine(
        trip: widget.trip,
        currentItems: currentItems,
        instruction: text,
        language: language,
      );
      ref
          .read(packingListProvider(widget.trip.id).notifier)
          .replaceAll(result.items);
      chat.addAssistant(result.reply);
    } catch (_) {
      chat.addAssistant(
        'No he podido procesar esa petición ahora mismo — inténtalo de nuevo en un momento.',
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(packingChatProvider(widget.trip.id));
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pide ajustes a la IA',
                    style: AppTextStyles.title.copyWith(color: onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Pídele lo que quieras, por ejemplo: "no llevo mucho espacio, optimiza la maleta" '
                          'o "añade cosas para hacer submarinismo".',
                          style: AppTextStyles.body.copyWith(color: secondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Align(
                          alignment: message.fromUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: message.fromUser
                                  ? AppColors.primary
                                  : Theme.of(
                                      context,
                                    ).inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message.text,
                              style: AppTextStyles.body.copyWith(
                                color: message.fromUser
                                    ? Colors.white
                                    : onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_isSending)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Ajustando la lista…',
                  style: AppTextStyles.caption.copyWith(color: secondary),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu petición…',
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSending ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
