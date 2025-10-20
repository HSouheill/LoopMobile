import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadChats();
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatConversationPage(
                                          chat: chat,
                                          otherParticipantName: otherParticipantName,
                                          otherParticipantImage: otherParticipantImage,
                                        ),
                                      ),
                                    );
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
