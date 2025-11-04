import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
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
  bool isLoadingMore = false;
  bool isInitialLoadComplete = false;
  String? currentUserId;
  String? token;
  int currentPage = 1;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _scrollController.addListener(_scrollListener);
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
              // Automatically mark as read when receiving a message while in the chat
              _markMessagesAsRead();
            }
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n != null ? l10n.errorInitializingChat(e.toString()) : 'Error initializing chat: $e')),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    if (token == null) return;

    try {
      // Get chat with messages (first page)
      final chatWithMessages = await ChatService.getChatWithUser(
        token!,
        widget.chat.participants.firstWhere((id) => id != currentUserId),
        page: 1,
        limit: 20,
      );

      if (chatWithMessages != null) {
        setState(() {
          // Reverse messages since backend returns newest first
          messages = (chatWithMessages.messages ?? []).reversed.toList();
          currentPage = chatWithMessages.pagination?.currentPage ?? 1;
          hasMore = chatWithMessages.pagination?.hasMore ?? false;
          isLoading = false;
        });
        
        // Scroll to bottom after initial load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            // Enable pagination after initial scroll is complete
            setState(() {
              isInitialLoadComplete = true;
            });
          }
        });
        
        // Automatically mark messages as read when entering the chat
        _markMessagesAsRead();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isInitialLoadComplete = true;
      });
    }
  }

  void _scrollListener() {
    // Only trigger pagination after initial load is complete
    if (!isInitialLoadComplete) return;
    
    if (_scrollController.position.pixels <= 100 && hasMore && !isLoadingMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (token == null || !hasMore || isLoadingMore) return;

    // Save the current scroll position before loading more messages
    final double previousScrollOffset = _scrollController.offset;
    final double previousMaxScrollExtent = _scrollController.position.maxScrollExtent;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final nextPage = currentPage + 1;
      final chatWithMessages = await ChatService.getChatWithUser(
        token!,
        widget.chat.participants.firstWhere((id) => id != currentUserId),
        page: nextPage,
        limit: 20,
      );

      if (chatWithMessages != null && mounted) {
        final newMessages = (chatWithMessages.messages ?? []).reversed.toList();
        setState(() {
          // Insert older messages at the beginning
          messages.insertAll(0, newMessages);
          currentPage = chatWithMessages.pagination?.currentPage ?? currentPage;
          hasMore = chatWithMessages.pagination?.hasMore ?? false;
          isLoadingMore = false;
        });

        // Restore scroll position to maintain seamless scrolling
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final double newMaxScrollExtent = _scrollController.position.maxScrollExtent;
            final double scrollDifference = newMaxScrollExtent - previousMaxScrollExtent;
            final double newScrollOffset = previousScrollOffset + scrollDifference;
            _scrollController.jumpTo(newScrollOffset);
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  // Mark messages as read via socket
  void _markMessagesAsRead() {
    // Use socket to mark messages as read
    SocketService.instance.markMessagesAsRead(widget.chat.id);
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
        firstName: AuthService.currentUser?.name.split(' ').first ?? (AppLocalizations.of(context)?.you ?? 'You'),
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
    } catch (e) {
      // Remove the temporary message if sending failed
      setState(() {
        messages.removeWhere((m) => m.id == tempMessage.id);
      });
      
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n != null ? l10n.errorSendingMessage(e.toString()) : 'Error sending message: $e')),
        );
      }
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n != null ? l10n.errorDeletingMessage(e.toString()) : 'Error deleting message: $e')),
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
    final l10n = AppLocalizations.of(context);
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
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n?.blockUser ?? 'Block User'),
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
                              l10n?.noMessagesYet ?? 'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n?.startConversationPrompt ?? 'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == currentUserId;
                              
                              return _buildMessageBubble(message, isMe);
                            },
                          ),
                          if (isLoadingMore)
                            Positioned(
                              top: 10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                      hintText: l10n?.typeAMessage ?? 'Type a message...',
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
                      message.sender?.fullName ?? (AppLocalizations.of(context)?.unknown ?? 'Unknown'),
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
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
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
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      const Icon(Icons.report, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)?.report ?? 'Report'),
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.blockUser ?? 'Block User'),
        content: Text(l10n?.blockUserConfirm ?? 'Are you sure you want to block this user? You won\'t be able to send or receive messages from them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _blockUser();
            },
            child: Text(l10n?.blockUser ?? 'Block', style: const TextStyle(color: Colors.red)),
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.userBlockedSuccessfully ?? 'User blocked successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n != null ? l10n.errorBlockingUser(e.toString()) : 'Error blocking user: $e')),
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
