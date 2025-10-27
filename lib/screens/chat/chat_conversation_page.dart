import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/chat_service.dart';
import '../../services/socket_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/message_report_dialog.dart';

class ChatConversationPage extends StatefulWidget {
  final Chat chat;
  final String otherParticipantName;
  final String? otherParticipantImage;

  const ChatConversationPage({
    super.key,
    required this.chat,
    required this.otherParticipantName,
    this.otherParticipantImage,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  bool isLoading = true;
  bool isTyping = false;
  String? currentUserId;
  String? token;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      token = AuthService.token;
      currentUserId = AuthService.currentUser?.id;
      
      if (token != null) {
        // Connect to socket
        await SocketService.instance.connect(token!, currentUserId!);
        
        // Join chat room
        SocketService.instance.joinChat(widget.chat.id);
        
        // Listen for new messages
        SocketService.instance.messageStream.listen((message) {
          if (message.chatId == widget.chat.id) {
            setState(() {
              // Check if message doesn't already exist in the list
              final existingIndex = messages.indexWhere((m) => m.id == message.id || 
                  (m.id.startsWith('temp_') && message.senderId == currentUserId));
              
              if (existingIndex == -1) {
                // New message, add it
                messages.add(message);
                // Only scroll if message is from other user
                if (message.senderId != currentUserId) {
                  _scrollToBottom();
                }
              } else {
                // Message already exists, replace it if it's from current user (temp -> real)
                if (message.senderId == currentUserId) {
                  messages[existingIndex] = message;
                }
                // If message is from other user and already exists, don't add it again
              }
            });
            
            // Scroll to bottom if message is from other user
            if (message.senderId != currentUserId) {
              _scrollToBottom();
            }
          }
        });

        // Listen for typing indicators
        SocketService.instance.typingStream.listen((data) {
          if (data['chatId'] == widget.chat.id && data['userId'] != currentUserId) {
            setState(() {
              isTyping = data['isTyping'] ?? false;
            });
          }
        });

        // Load existing messages
        await _loadMessages();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing chat: $e')),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    if (token == null) return;

    try {
      // Get chat with messages
      final chatWithMessages = await ChatService.getChatWithUser(
        token!,
        widget.chat.participants.firstWhere((id) => id != currentUserId),
      );

      if (chatWithMessages != null) {
        setState(() {
          messages = chatWithMessages.messages ?? [];
          isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || token == null) return;

    _messageController.clear();

    // Create a temporary message to show immediately
    final tempMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.chat.id,
      senderId: currentUserId!,
      content: content,
      createdAt: DateTime.now(),
      sender: Sender(
        id: currentUserId!,
        firstName: AuthService.currentUser?.name.split(' ').first ?? 'You',
        lastName: (AuthService.currentUser?.name.split(' ').length ?? 0) > 1 
            ? AuthService.currentUser!.name.split(' ').skip(1).join(' ') 
            : '',
        profileImage: AuthService.currentUser?.profileImage,
      ),
    );

    // Add the message to the UI immediately
    setState(() {
      messages.add(tempMessage);
    });
    _scrollToBottom();

    try {
      // Send via API (backend will emit Socket.IO event)
      final sentMessage = await ChatService.sendMessage(
        token: token!,
        chatId: widget.chat.id,
        content: content,
      );

      if (sentMessage != null) {
        // The Socket.IO event will replace the temp message automatically
        // No need to manually replace it here
      }

      // Mark messages as read
      await ChatService.markMessagesAsRead(token!, widget.chat.id);
    } catch (e) {
      // Remove the temporary message if sending failed
      setState(() {
        messages.removeWhere((m) => m.id == tempMessage.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  void _onTypingChanged(bool isTyping) {
    if (isTyping) {
      SocketService.instance.startTyping(widget.chat.id);
    } else {
      SocketService.instance.stopTyping(widget.chat.id);
    }
  }

  Future<void> _deleteMessage(Message message) async {
    if (token == null) return;

    try {
      final success = await ChatService.deleteMessage(token!, message.id);
      if (success && mounted) {
        setState(() {
          messages.removeWhere((m) => m.id == message.id);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting message: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    SocketService.instance.leaveChat(widget.chat.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[600],
              child: Text(
                widget.otherParticipantName.isNotEmpty 
                    ? widget.otherParticipantName[0].toUpperCase() 
                    : '?',
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherParticipantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  if (isTyping)
                    const Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'block') {
                _showBlockUserDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Block User'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chatbg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == currentUserId;
                          
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      _onTypingChanged(value.isNotEmpty);
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 27, 55, 147),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[600],
              child: Text(
                widget.otherParticipantName.isNotEmpty 
                    ? widget.otherParticipantName[0].toUpperCase() 
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe 
                    ? const Color.fromARGB(255, 27, 55, 147)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.sender?.fullName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteMessage(message);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, size: 16),
            ),
          ] else ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  _showReportMessageDialog(message);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Report'),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showBlockUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user? You won\'t be able to send or receive messages from them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _blockUser();
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _blockUser() async {
    if (token == null) return;

    try {
      final otherUserId = widget.chat.participants.firstWhere(
        (id) => id != currentUserId,
      );
      
      final success = await ChatService.blockUser(
        token: token!,
        blockedUserId: otherUserId,
        reason: 'Blocked by user',
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User blocked successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error blocking user: $e')),
        );
      }
    }
  }

  void _showReportMessageDialog(Message message) {
    showDialog(
      context: context,
      builder: (context) => MessageReportDialog(
        messageId: message.id,
        messageContent: message.content,
      ),
    );
  }
}
