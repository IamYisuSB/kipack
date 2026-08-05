import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

/// In-memory conversation history per trip for the "ask the AI to adjust
/// my list" chat. Deliberately not persisted to disk — it's a transient
/// aid for getting to a good list, not data worth keeping across restarts.
class PackingChatNotifier extends StateNotifier<List<ChatMessage>> {
  PackingChatNotifier() : super(const []);

  void addUser(String text) =>
      state = [...state, ChatMessage(fromUser: true, text: text)];

  void addAssistant(String text) =>
      state = [...state, ChatMessage(fromUser: false, text: text)];
}

final packingChatProvider =
    StateNotifierProvider.family<
      PackingChatNotifier,
      List<ChatMessage>,
      String
    >((ref, tripId) {
      return PackingChatNotifier();
    });
