import 'local_storage_service.dart';
import '../models/message.dart';
import 'notification_service.dart';

class MessageService {
  final LocalStorageService _storage = LocalStorageService();

  String _conversationId(String userAId, String userBId, String petName) {
    final ids = [userAId, userBId]..sort();
    return '${ids[0]}_${ids[1]}_$petName';
  }

  Future<List<Message>> getMessagesForConversation(
    String currentUserId,
    String otherUserId,
    String petName,
  ) async {
    final conversationId = _conversationId(currentUserId, otherUserId, petName);
    final messages = await _storage.getMessages();
    final conversationMessages = messages
        .where((m) => m['conversationId'] == conversationId)
        .toList();
    conversationMessages.sort((a, b) => (a['timestamp'] as String).compareTo(b['timestamp'] as String));
    return conversationMessages.map((m) => Message.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    final messages = await _storage.getMessages();
    final userMessages = messages.where((m) => m['participants'] != null && (m['participants'] as List).contains(userId)).toList();

    final conversations = <String, Map<String, dynamic>>{};
    for (final msg in userMessages) {
      final convId = msg['conversationId'] as String? ?? '';
      if (convId.isEmpty) continue;

      final senderId = msg['senderId'] as String? ?? '';
      final receiverId = msg['receiverId'] as String? ?? '';
      final otherUserId = senderId == userId ? receiverId : senderId;
      final otherUserName = senderId == userId
          ? (msg['receiverName'] as String? ?? 'Unknown')
          : (msg['senderName'] as String? ?? 'Unknown');
      final petName = msg['petName'] as String? ?? '';

      if (!conversations.containsKey(convId)) {
        final content = msg['content'] as String? ?? '';
        final hasImage = msg['imageBase64'] != null;
        conversations[convId] = {
          'conversationId': convId,
          'otherUserId': otherUserId,
          'otherUserName': otherUserName,
          'petName': petName,
          'lastMessage': content.isNotEmpty ? content : (hasImage ? 'Photo' : ''),
          'lastTimestamp': msg['timestamp'] is String
              ? DateTime.parse(msg['timestamp'] as String).millisecondsSinceEpoch
              : 0,
          'unreadCount': 0,
        };
      }
    }

    final result = conversations.values.toList();
    result.sort((a, b) => (b['lastTimestamp'] as int).compareTo(a['lastTimestamp'] as int));
    return result;
  }

  bool _isSending = false;

  Future<void> sendMessage(
    String userId,
    String senderName,
    String receiverId,
    String receiverName,
    String petName,
    String content, {
    String? imageBase64,
  }) async {
    final trimmedContent = content.trim();
    final hasImage = imageBase64 != null && imageBase64.isNotEmpty;
    if (trimmedContent.isEmpty && !hasImage) return;
    if (_isSending) return;
    _isSending = true;

    try {
      final conversationId = _conversationId(userId, receiverId, petName);
      final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      final message = Message(
        id: messageId,
        conversationId: conversationId,
        senderId: userId,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        petName: petName,
        content: trimmedContent,
        imageBase64: hasImage ? imageBase64 : null,
        timestamp: now,
      );

      final messages = await _storage.getMessages();
      messages.add(message.toMap());
      await _storage.saveMessages(messages);

      NotificationService.showMessageNotification(
        senderName: senderName,
        message: hasImage ? '$senderName sent a photo' : trimmedContent,
      );
    } catch (_) {
    } finally {
      _isSending = false;
    }
  }

  Future<void> markConversationAsRead(
    String currentUserId,
    String otherUserId,
    String petName,
  ) async {
    // TODO: implement read receipts
  }
}