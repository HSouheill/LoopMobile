import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../services/socket_service.dart';
import 'chat_conversation_page.dart';
import 'blocked_users_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Chat> chats = [];
  bool isLoading = true;
  String? currentUserId;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _readSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _loadChats();
  }

  Future<void> _initializeSocket() async {
    try {
      final token = AuthService.token;
      final userId = AuthService.currentUser?.id;
      
      if (token != null && userId != null) {
        currentUserId = userId;
        
        print('ChatListPage: Initializing socket for user $userId');
        
        // Connect to socket
        await SocketService.instance.connect(token, userId);
        
        print('ChatListPage: Socket connected, setting up listeners');
        
        // Cancel any existing subscriptions first
        await _messageSubscription?.cancel();
        await _notificationSubscription?.cancel();
        await _readSubscription?.cancel();
        
        // Listen for new messages to update chat list
        _messageSubscription = SocketService.instance.messageStream.listen(
          (message) {
            print('ChatListPage: Received new message for chat: ${message.chatId}, content: ${message.content}');
            _handleNewMessage(message);
          },
          onError: (error) {
            print('ChatListPage: Error in message stream: $error');
          },
        );

        // Listen for message notifications to update unread counts
        _notificationSubscription = SocketService.instance.notificationStream.listen(
          (data) {
            print('ChatListPage: Received notification for chat: ${data['chatId']}, unreadCount: ${data['unreadCount']}');
            _handleMessageNotification(data);
          },
          onError: (error) {
            print('ChatListPage: Error in notification stream: $error');
          },
        );

        // Listen for messages_read event to update unread counts
        _readSubscription = SocketService.instance.readStream.listen(
          (data) {
            print('ChatListPage: Received messages_read for chat: ${data['chatId']}, readBy: ${data['readBy']}');
            _handleMessagesRead(data);
          },
          onError: (error) {
            print('ChatListPage: Error in read stream: $error');
          },
        );
        
        print('ChatListPage: All listeners set up successfully');
      }
    } catch (e) {
      print('ChatListPage: Error initializing socket: $e');
    }
  }

  void _handleNewMessage(Message message) {
    print('ChatListPage: _handleNewMessage called, mounted: $mounted');
    if (!mounted) {
      print('ChatListPage: Not mounted, skipping update');
      return;
    }
    
    print('ChatListPage: Updating chat list for message in chat ${message.chatId}');
    
    // Update the chat in the list with the new message
    setState(() {
      final chatIndex = chats.indexWhere((chat) => chat.id == message.chatId);
      print('ChatListPage: Found chat at index: $chatIndex');
      
      if (chatIndex != -1) {
        final chat = chats[chatIndex];
        final newUnreadCount = message.senderId != currentUserId 
            ? chat.unreadCount + 1 
            : chat.unreadCount;
        
        print('ChatListPage: Updating chat - Old unread: ${chat.unreadCount}, New unread: $newUnreadCount');
        
        final updatedChat = Chat(
          id: chat.id,
          participants: chat.participants,
          lastMessage: message.content,
          lastMessageAt: message.createdAt,
          isActive: chat.isActive,
          unreadCount: newUnreadCount,
          participantDetails: chat.participantDetails,
          messages: chat.messages,
        );
        
        // Remove from current position and add to top
        chats.removeAt(chatIndex);
        chats.insert(0, updatedChat);
        
        print('ChatListPage: Chat moved to top of list');
      } else {
        print('ChatListPage: Chat not found in list, might need to refresh');
      }
    });
  }

  void _handleMessageNotification(Map<String, dynamic> data) {
    print('ChatListPage: _handleMessageNotification called, mounted: $mounted');
    if (!mounted) {
      print('ChatListPage: Not mounted, skipping notification update');
      return;
    }
    
    final chatId = data['chatId'] as String?;
    final unreadCount = data['unreadCount'] as int?;
    
    print('ChatListPage: Notification - chatId: $chatId, unreadCount: $unreadCount');
    
    if (chatId != null && unreadCount != null) {
      setState(() {
        final chatIndex = chats.indexWhere((chat) => chat.id == chatId);
        print('ChatListPage: Found chat at index: $chatIndex for notification');
        
        if (chatIndex != -1) {
          final chat = chats[chatIndex];
          print('ChatListPage: Updating unread count from ${chat.unreadCount} to $unreadCount');
          
          chats[chatIndex] = Chat(
            id: chat.id,
            participants: chat.participants,
            lastMessage: chat.lastMessage,
            lastMessageAt: chat.lastMessageAt,
            isActive: chat.isActive,
            unreadCount: unreadCount,
            participantDetails: chat.participantDetails,
            messages: chat.messages,
          );
        }
      });
    }
  }

  void _handleMessagesRead(Map<String, dynamic> data) {
    print('ChatListPage: _handleMessagesRead called, mounted: $mounted');
    if (!mounted) {
      print('ChatListPage: Not mounted, skipping read update');
      return;
    }
    
    final chatId = data['chatId'] as String?;
    final readBy = data['readBy'] as String?;
    
    print('ChatListPage: Messages read - chatId: $chatId, readBy: $readBy, currentUserId: $currentUserId');
    
    // Update unread count when current user reads messages
    if (chatId != null && readBy != null && readBy == currentUserId) {
      print('ChatListPage: Current user read messages, resetting unread count to 0');
      
      setState(() {
        final chatIndex = chats.indexWhere((chat) => chat.id == chatId);
        print('ChatListPage: Found chat at index: $chatIndex for read update');
        
        if (chatIndex != -1) {
          final chat = chats[chatIndex];
          print('ChatListPage: Setting unread count from ${chat.unreadCount} to 0');
          
          chats[chatIndex] = Chat(
            id: chat.id,
            participants: chat.participants,
            lastMessage: chat.lastMessage,
            lastMessageAt: chat.lastMessageAt,
            isActive: chat.isActive,
            unreadCount: 0, // Messages were read by current user
            participantDetails: chat.participantDetails,
            messages: chat.messages,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _notificationSubscription?.cancel();
    _readSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadChats() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = AuthService.token;
      if (token != null && AuthService.isLoggedIn) {
        currentUserId = AuthService.currentUser?.id;
        final chatList = await ChatService.getUserChats(token);
        setState(() {
          chats = chatList;
          isLoading = false;
        });
      } else {
        // User is not authenticated, stop loading
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to access your chats'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chats: $e')),
        );
      }
    }
  }

  String _getOtherParticipantName(Chat chat) {
    if (chat.participantDetails.length < 2) return 'Unknown';
    
    // Find the other participant (not the current user)
    for (final participant in chat.participantDetails) {
      if (participant.id != currentUserId) {
        return participant.fullName;
      }
    }
    return 'Unknown';
  }

  String? _getOtherParticipantImage(Chat chat) {
    if (chat.participantDetails.length < 2) return null;
    
    // Find the other participant (not the current user)
    for (final participant in chat.participantDetails) {
      if (participant.id != currentUserId) {
        return participant.profileImage;
      }
    }
    return null;
  }

  String _formatLastMessageTime(DateTime? lastMessageAt) {
    if (lastMessageAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and unread count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (chats.any((chat) => chat.unreadCount > 0))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Unread ${chats.fold(0, (sum, chat) => sum + chat.unreadCount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Icon(Icons.tune, color: Colors.black87, size: 20),
                ],
              ),
            ),
            
            // Green separator line
            Container(
              height: 2,
              color: Colors.green,
            ),
            
            // Chat list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : chats.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AuthService.isLoggedIn ? 'No chats yet' : 'Please sign in to chat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AuthService.isLoggedIn 
                                    ? 'Start a conversation with someone'
                                    : 'Sign in to access your chats and start conversations',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadChats,
                          child: ListView.builder(
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              final chat = chats[index];
                              final otherParticipantName = _getOtherParticipantName(chat);
                              final otherParticipantImage = _getOtherParticipantImage(chat);
                              
                              return Container(
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.blue[600],
                                    child: Text(
                                      otherParticipantName.isNotEmpty 
                                          ? otherParticipantName[0].toUpperCase() 
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    otherParticipantName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          chat.lastMessage ?? 'No messages yet',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatLastMessageTime(chat.lastMessageAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      if (chat.unreadCount > 0) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            chat.unreadCount > 99 
                                                ? '99+' 
                                                : chat.unreadCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: () async {
                                    // Set unread count to 0 immediately for better UX
                                    setState(() {
                                      final chatIndex = chats.indexWhere((c) => c.id == chat.id);
                                      if (chatIndex != -1) {
                                        final currentChat = chats[chatIndex];
                                        chats[chatIndex] = Chat(
                                          id: currentChat.id,
                                          participants: currentChat.participants,
                                          lastMessage: currentChat.lastMessage,
                                          lastMessageAt: currentChat.lastMessageAt,
                                          isActive: currentChat.isActive,
                                          unreadCount: 0,
                                          participantDetails: currentChat.participantDetails,
                                          messages: currentChat.messages,
                                        );
                                      }
                                    });
                                    
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatConversationPage(
                                          chat: chat,
                                          otherParticipantName: otherParticipantName,
                                          otherParticipantImage: otherParticipantImage,
                                        ),
                                      ),
                                    );
                                    // No need to reload chats - socket events handle updates
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
            
            // Bottom section with blocked contacts link
          Container(
  padding: EdgeInsets.only(
    left: 16,
    top: 16,
    right: 16,
    bottom: 46,
  ),
  color: const Color.fromARGB(0, 255, 255, 255),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BlockedUsersPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'See Blocked Contacts',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
