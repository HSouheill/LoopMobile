import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/blocked_user.dart';

class ChatService {
  static const String baseUrl = '${Environment.apiUrl}chat/';

  // Get all chats for authenticated user
  static Future<List<Chat>> getUserChats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          try {
            return (data['chats'] as List)
                .map((chat) => Chat.fromJson(chat))
                .toList();
          } catch (parseError) {
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get chat with specific user
  static Future<Chat?> getChatWithUser(String token, String otherUserId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}chats/with/$otherUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          try {
            return Chat.fromJson(data['chat']);
          } catch (parseError) {
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Send message
  static Future<Message?> sendMessage({
    required String token,
    required String chatId,
    required String content,
    String messageType = 'text',
    List<String> attachments = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'chatId': chatId,
          'content': content,
          'messageType': messageType,
          'attachments': attachments,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Message.fromJson(data['message']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Mark messages as read
  static Future<bool> markMessagesAsRead(String token, String chatId) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}chats/$chatId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get total unread count
  static Future<int> getUnreadCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['unreadCount'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Block user
  static Future<bool> blockUser({
    required String token,
    required String blockedUserId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}block'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'blockedUserId': blockedUserId,
          'reason': reason,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Unblock user
  static Future<bool> unblockUser(String token, String blockedUserId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}block/$blockedUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get blocked users
  static Future<List<BlockedUser>> getBlockedUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}blocked'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['blockedUsers'] as List)
              .map((blockedUser) => BlockedUser.fromJson(blockedUser))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Delete message
  static Future<bool> deleteMessage(String token, String messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}messages/$messageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Search users for chat
  static Future<List<User>> searchUsers(String token, String query) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}search-users?query=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['users'] as List)
              .map((user) => User.fromJson(user))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Create a new chat with a user
  static Future<Chat?> createChat({
    required String token,
    required String otherUserId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'otherUserId': otherUserId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          try {
            return Chat.fromJson(data['chat']);
          } catch (parseError) {
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
