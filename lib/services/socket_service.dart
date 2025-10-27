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
  final StreamController<Map<String, dynamic>> _typingController = StreamController<Map<String, dynamic>>.broadcast();
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
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get readStream => _readController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get chatUpdateStream => _chatUpdateController.stream;

  // Connect to socket server
  Future<void> connect(String token, String userId) async {
    if (_isConnected && _token == token && _socket != null) {
      print('Socket already connected');
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
      final socketUrl = 'http://${uri.host}:${uri.port}';
      
      print('Connecting to Socket.IO: $socketUrl');
      
      _socket = IO.io(socketUrl, IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build());

      _setupEventListeners();
      _socket!.connect();
      
      print('Socket.IO service connecting...');
    } catch (e) {
      print('Error connecting to socket: $e');
      _isConnected = false;
      // Fallback: continue without Socket.IO, the app will work but won't have real-time updates
    }
  }

  bool _listenersSetup = false;

  void _setupEventListeners() {
    if (_socket == null || _listenersSetup) return;
    _listenersSetup = true;

    // Connection events
    _socket!.onConnect((_) {
      print('Socket.IO connected');
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      print('Socket.IO disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('Socket.IO connection error: $error');
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
        print('Error handling new_message: $e');
        print('Data type: ${data.runtimeType}');
        print('Data: $data');
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
        print('Error handling message_notification: $e');
      }
    });

    _socket!.on('user_typing', (data) {
      try {
        final typingData = data is Map<String, dynamic> 
            ? data 
            : Map<String, dynamic>.from(data as Map);
        _typingController.add(typingData);
      } catch (e) {
        print('Error handling user_typing: $e');
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
        print('Error handling messages_read: $e');
      }
    });

    _socket!.on('user_status_updated', (data) {
      try {
        final statusData = data is Map<String, dynamic> 
            ? data 
            : Map<String, dynamic>.from(data as Map);
        _statusController.add(statusData);
      } catch (e) {
        print('Error handling user_status_updated: $e');
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
        print('Error handling user_offline: $e');
      }
    });

    _socket!.on('error', (data) {
      print('Socket.IO error: $data');
    });

    // Chat room events
    _socket!.on('joined_chat', (data) {
      print('Joined chat: ${data['chatId']}');
    });

    _socket!.on('left_chat', (data) {
      print('Left chat: ${data['chatId']}');
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
    print('Socket.IO service disconnected');
  }

  // Join a chat room
  void joinChat(String chatId) {
    _joinedRooms.add(chatId);
    
    if (!_isConnected || _socket == null) {
      print('Cannot join chat: not connected to socket');
      return;
    }

    try {
      _socket!.emit('join_chat', chatId);
      print('Joining chat: $chatId');
    } catch (e) {
      print('Error joining chat: $e');
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
      print('Leaving chat: $chatId');
    } catch (e) {
      print('Error leaving chat: $e');
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
      print('Cannot send message: not connected to socket');
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
      print('Error sending message via socket: $e');
    }
  }

  // Start typing indicator
  void startTyping(String chatId) {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('typing_start', {'chatId': chatId});
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  // Stop typing indicator
  void stopTyping(String chatId) {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('typing_stop', {'chatId': chatId});
    } catch (e) {
      print('Error stopping typing indicator: $e');
    }
  }

  // Mark messages as read
  void markMessagesAsRead(String chatId) {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('mark_read', {'chatId': chatId});
      print('Marking messages as read in chat: $chatId');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Update user status
  void updateStatus(String status) {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('update_status', {'status': status});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // Check if connected
  bool get isConnected => _isConnected;

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _notificationController.close();
    _typingController.close();
    _readController.close();
    _statusController.close();
    _chatUpdateController.close();
  }
}