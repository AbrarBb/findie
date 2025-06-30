import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/message_model.dart';

class MessageService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Send message
  Future<MessageModel?> sendMessage({
    required String toUserId,
    required String postId,
    required String message,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('messages').insert({
        'from_user_id': user.id,
        'to_user_id': toUserId,
        'post_id': postId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      }).select('''
        *,
        from_user:users!from_user_id(*)
      ''').single();

      return MessageModel.fromJson(response);
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Get messages for a post
  Future<List<MessageModel>> getMessagesForPost(String postId) async {
    try {
      final response = await _client
          .from('messages')
          .select('''
            *,
            from_user:users!from_user_id(*)
          ''')
          .eq('post_id', postId)
          .order('timestamp', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Get conversations for current user
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('messages')
          .select('''
            *,
            from_user:users!from_user_id(*),
            to_user:users!to_user_id(*),
            post:posts(*)
          ''')
          .or('from_user_id.eq.${user.id},to_user_id.eq.${user.id}')
          .order('timestamp', ascending: false);

      // Group by post_id and get latest message for each conversation
      final conversations = <String, Map<String, dynamic>>{};
      
      for (final message in response) {
        final postId = message['post_id'] as String;
        if (!conversations.containsKey(postId)) {
          conversations[postId] = message;
        }
      }

      return conversations.values.toList();
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required String postId,
    required String fromUserId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('post_id', postId)
          .eq('from_user_id', fromUserId)
          .eq('to_user_id', user.id);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Listen to new messages for a post
  Stream<MessageModel> listenToMessages(String postId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .map((data) => MessageModel.fromJson(data.first));
  }
}

// Provider for MessageService
final messageServiceProvider = Provider<MessageService>((ref) => MessageService());

// Provider for messages
final messagesProvider = FutureProvider.family<List<MessageModel>, String>((ref, postId) async {
  final messageService = ref.watch(messageServiceProvider);
  return await messageService.getMessagesForPost(postId);
});

// Provider for conversations
final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final messageService = ref.watch(messageServiceProvider);
  return await messageService.getConversations();
});