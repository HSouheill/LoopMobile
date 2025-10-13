class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final List<String> attachments;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final Sender? sender;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.attachments = const [],
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.isDeleted = false,
    this.deletedAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Handle chat field - it can be an ObjectId or populated chat object
    String chatId = '';
    if (json['chat'] != null) {
      if (json['chat'] is String) {
        chatId = json['chat'];
      } else if (json['chat'] is Map<String, dynamic>) {
        chatId = json['chat']['_id'] ?? json['chat']['id'] ?? '';
      }
    }

    // Handle sender field - it can be an ObjectId or populated user object
    String senderId = '';
    Sender? sender;
    if (json['sender'] != null) {
      if (json['sender'] is String) {
        senderId = json['sender'];
      } else if (json['sender'] is Map<String, dynamic>) {
        senderId = json['sender']['_id'] ?? json['sender']['id'] ?? '';
        sender = Sender.fromJson(json['sender']);
      }
    }

    // Handle attachments - they are objects with filename, url, etc.
    List<String> attachmentUrls = [];
    if (json['attachments'] != null && json['attachments'] is List) {
      for (final attachment in json['attachments']) {
        if (attachment is Map<String, dynamic> && attachment['url'] != null) {
          attachmentUrls.add(attachment['url']);
        }
      }
    }

    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      chatId: chatId,
      senderId: senderId,
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      attachments: attachmentUrls,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt']) 
          : null,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null 
          ? DateTime.parse(json['deletedAt']) 
          : null,
      sender: sender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat': chatId,
      'sender': senderId,
      'content': content,
      'messageType': messageType,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

class Sender {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;

  Sender({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  String get fullName => '$firstName $lastName';
}
