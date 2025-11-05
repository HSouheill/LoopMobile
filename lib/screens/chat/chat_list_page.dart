import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _loadChats();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeSocket() async {
    try {
      final token = AuthService.token;
      final userId = AuthService.currentUser?.id;
      
      if (token != null && userId != null) {
        currentUserId = userId;
        
        // Connect to socket
        await SocketService.instance.connect(token, userId);
        
        // Cancel any existing subscriptions first
        await _messageSubscription?.cancel();
        await _notificationSubscription?.cancel();
        await _readSubscription?.cancel();
        
        // Listen for new messages to update chat list
        _messageSubscription = SocketService.instance.messageStream.listen(
          (message) {
            _handleNewMessage(message);
          },
        );

        // Listen for message notifications to update unread counts
        _notificationSubscription = SocketService.instance.notificationStream.listen(
          (data) {
            _handleMessageNotification(data);
          },
        );

        // Listen for messages_read event to update unread counts
        _readSubscription = SocketService.instance.readStream.listen(
          (data) {
            _handleMessagesRead(data);
          },
        );
      }
    } catch (e) {
      // Silently fail
    }
  }

  void _handleNewMessage(Message message) {
    if (!mounted) return;
    
    // Update the chat in the list with the new message
    // Don't update unread count here - it will be updated by message_notification event
    setState(() {
      final chatIndex = chats.indexWhere((chat) => chat.id == message.chatId);
      
      if (chatIndex != -1) {
        final chat = chats[chatIndex];
        
        final updatedChat = Chat(
          id: chat.id,
          participants: chat.participants,
          lastMessage: message.content,
          lastMessageAt: message.createdAt,
          isActive: chat.isActive,
          unreadCount: chat.unreadCount, // Keep existing count, will be updated by notification
          participantDetails: chat.participantDetails,
          messages: chat.messages,
        );
        
        // Remove from current position and add to top
        chats.removeAt(chatIndex);
        chats.insert(0, updatedChat);
      }
    });
  }

  void _handleMessageNotification(Map<String, dynamic> data) {
    if (!mounted) return;
    
    final chatId = data['chatId'] as String?;
    final unreadCount = data['unreadCount'] as int?;
    
    if (chatId != null && unreadCount != null) {
      setState(() {
        final chatIndex = chats.indexWhere((chat) => chat.id == chatId);
        
        if (chatIndex != -1) {
          final chat = chats[chatIndex];
          
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
    if (!mounted) return;
    
    final chatId = data['chatId'] as String?;
    final readBy = data['readBy'] as String?;
    
    // Update unread count when current user reads messages
    if (chatId != null && readBy != null && readBy == currentUserId) {
      setState(() {
        final chatIndex = chats.indexWhere((chat) => chat.id == chatId);
        
        if (chatIndex != -1) {
          final chat = chats[chatIndex];
          
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
    _searchDebounce?.cancel();
    _searchController.dispose();
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
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.pleaseSignInToAccessChats ?? 'Please sign in to access your chats'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n != null ? l10n.errorLoadingChats(e.toString()) : 'Error loading chats: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      final token = AuthService.token;
      if (token == null || !AuthService.isLoggedIn) return;

      if (query.isEmpty) {
        // Reset to full list
        await _loadChats();
        return;
      }

      // Only search if query is at least 2 characters (backend requirement)
      if (query.length < 2) {
        // If query is less than 2 characters, show empty results
        setState(() {
          chats = [];
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
      });
      try {
        final results = await ChatService.searchChats(token, query);
        if (!mounted) return;
        setState(() {
          chats = results;
          _isSearching = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSearching = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n != null ? l10n.errorLoadingChats(e.toString()) : 'Error searching chats: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  String _getOtherParticipantName(Chat chat, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (chat.participantDetails.length < 2) return l10n?.unknown ?? 'Unknown';
    
    // Find the other participant (not the current user)
    for (final participant in chat.participantDetails) {
      if (participant.id != currentUserId) {
        return participant.fullName;
      }
    }
    return l10n?.unknown ?? 'Unknown';
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

  String _formatLastMessageTime(DateTime? lastMessageAt, BuildContext context) {
    if (lastMessageAt == null) return '';
    
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);
    
    if (difference.inDays > 0) {
      return l10n != null ? l10n.daysAgo(difference.inDays) : '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return l10n != null ? l10n.hoursAgo(difference.inHours) : '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return l10n != null ? l10n.minutesAgo(difference.inMinutes) : '${difference.inMinutes}m ago';
    } else {
      return l10n?.justNow ?? 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  final unreadCount = chats.fold(0, (sum, chat) => sum + chat.unreadCount);
                  return Row(
                    children: [
                      Text(
                        l10n?.chat ?? 'Chat',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n != null ? l10n.unreadCount(unreadCount) : 'Unread $unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Row(
                    children: [
                      Icon(Icons.search, color: const Color.fromARGB(255, 69, 100, 201), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          cursorColor: const Color.fromARGB(255, 69, 100, 201),
                          decoration: InputDecoration(
                            hintText: l10n?.search ?? 'Search...',
                            hintStyle: const TextStyle(color: Color.fromARGB(255, 69, 100, 201)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_isSearching)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  );
                },
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
                                AuthService.isLoggedIn 
                                    ? (l10n?.noChatsYet ?? 'No chats yet') 
                                    : (l10n?.pleaseSignInToChat ?? 'Please sign in to chat'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AuthService.isLoggedIn 
                                    ? (l10n?.startConversation ?? 'Start a conversation with someone')
                                    : (l10n?.signInToAccessChatsDescription ?? 'Sign in to access your chats and start conversations'),
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
                              final otherParticipantName = _getOtherParticipantName(chat, context);
                              final otherParticipantImage = _getOtherParticipantImage(chat);
                              final l10n = AppLocalizations.of(context);
                              
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
                                          chat.lastMessage ?? (l10n?.noMessagesYet ?? 'No messages yet'),
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
                                        _formatLastMessageTime(chat.lastMessageAt, context),
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
                  child: Text(
                    l10n?.seeBlockedContacts ?? 'See Blocked Contacts',
                    style: const TextStyle(
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
