import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';
import '../environment.dart';

class SocketService {
  static SocketService? _instance;
  String? _token;
  IO.Socket? _socket;
  bool _isConnected = false;
  Set<String> _joinedRooms = {};
  
  // Stream controllers for real-time updates
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _readController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _chatUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  SocketService._();

  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  // Getters for streams
  Stream<Message> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get readStream => _readController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get chatUpdateStream => _chatUpdateController.stream;

  // Connect to socket server
  Future<void> connect(String token, String userId) async {
    if (_isConnected && _token == token && _socket != null) {
      return;
    }

    // Disconnect existing socket if token changed
    if (_socket != null && _token != token) {
      _socket!.disconnect();
      _socket = null;
    }

    _token = token;

    try {
      // Extract base URL from API URL
      final apiUrl = Environment.apiUrl;
      final uri = Uri.parse(apiUrl.replaceFirst('/api/', ''));
      final socketUrl = 'https://${uri.host}:${uri.port}'; //!CHANGE TO HTTPS FOR PRODUCTION DEPLOYMENT
      
      _socket = IO.io(socketUrl, IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build());

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      _isConnected = false;
    }
  }

  bool _listenersSetup = false;

  void _setupEventListeners() {
    if (_socket == null || _listenersSetup) return;
    _listenersSetup = true;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
    });

    // Chat events
    _socket!.on('new_message', (data) {
      try {
        // Convert data to Map<String, dynamic> if needed
        Map<String, dynamic> messageData;
        if (data is Map<String, dynamic>) {
          messageData = data;
        } else if (data is Map) {
          messageData = Map<String, dynamic>.from(data);
        } else {
          messageData = Map<String, dynamic>.from(data as Map);
        }
        
        final message = Message.fromJson(messageData);
        _messageController.add(message);
        
        // Also emit as chat update
        _chatUpdateController.add({
          'chatId': message.chatId,
          'type': 'message_added',
          'message': messageData,
        });
      } catch (e) {
        // Silently fail - error handling in production
      }
    });

    _socket!.on('message_notification', (data) {
      try {
        // Convert data to Map if needed
        final notificationData = data is Map<String, dynamic> 
            ? data 
            : Map<String, dynamic>.from(data as Map);
        
        _notificationController.add(notificationData);
        
        // Also emit as chat update for unread count
        _chatUpdateController.add({
          'chatId': notificationData['chatId'],
          'type': 'unread_updated',
          'unreadCount': notificationData['unreadCount'],
        });
      } catch (e) {
        // Silently fail - error handling in production
      }
    });

    _socket!.on('messages_read', (data) {
      try {
        final readData = data is Map<String, dynamic> 
            ? data 
            : Map<String, dynamic>.from(data as Map);
        
        _readController.add(readData);
        
        // Also emit as chat update
        _chatUpdateController.add({
          'chatId': readData['chatId'],
          'type': 'messages_read',
          'readBy': readData['readBy'],
        });
      } catch (e) {
        // Silently fail - error handling in production
      }
    });

    _socket!.on('user_status_updated', (data) {
      try {
        final statusData = data is Map<String, dynamic> 
            ? data 
            : Map<String, dynamic>.from(data as Map);
        _statusController.add(statusData);
      } catch (e) {
        // Silently fail - error handling in production
      }
    });

    _socket!.on('user_offline', (data) {
      try {
        final offlineData = data is Map<String, dynamic> 
            ? data 
            : Map<String, dynamic>.from(data as Map);
        _statusController.add({
          'userId': offlineData['userId'],
          'status': 'offline',
        });
      } catch (e) {
        // Silently fail - error handling in production
      }
    });

    _socket!.on('error', (data) {
      // Silently fail - error handling in production
    });

    // Chat room events
    _socket!.on('joined_chat', (data) {
      // Chat joined successfully
    });

    _socket!.on('left_chat', (data) {
      // Chat left successfully
    });
  }

  // Disconnect from socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _token = null;
    _isConnected = false;
    _joinedRooms.clear();
  }

  // Join a chat room
  void joinChat(String chatId) {
    _joinedRooms.add(chatId);
    
    if (!_isConnected || _socket == null) {
      return;
    }

    try {
      _socket!.emit('join_chat', chatId);
    } catch (e) {
      // Silently fail
    }
  }

  // Leave a chat room
  void leaveChat(String chatId) {
    _joinedRooms.remove(chatId);
    
    if (!_isConnected || _socket == null) {
      return;
    }

    try {
      _socket!.emit('leave_chat', chatId);
    } catch (e) {
      // Silently fail
    }
  }

  // Send a message
  void sendMessage({
    required String chatId,
    required String content,
    String messageType = 'text',
    List<String> attachments = const [],
  }) {
    if (!_isConnected || _socket == null) {
      return;
    }

    try {
      _socket!.emit('send_message', {
        'chatId': chatId,
        'content': content,
        'messageType': messageType,
        'attachments': attachments,
      });
    } catch (e) {
      // Silently fail
    }
  }

  // Mark messages as read
  void markMessagesAsRead(String chatId) {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('mark_read', {'chatId': chatId});
    } catch (e) {
      // Silently fail
    }
  }

  // Update user status
  void updateStatus(String status) {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('update_status', {'status': status});
    } catch (e) {
      // Silently fail
    }
  }

  // Check if connected
  bool get isConnected => _isConnected;

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _notificationController.close();
    _readController.close();
    _statusController.close();
    _chatUpdateController.close();
  }
}