import 'message.dart';

class Chat {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isActive;
  final int unreadCount;
  final List<Participant> participantDetails;
  final List<Message>? messages;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    required this.isActive,
    this.unreadCount = 0,
    this.participantDetails = const [],
    this.messages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    // Handle participants - they can be either strings (IDs) or objects
    List<String> participantIds = [];
    List<Participant> participantDetails = [];
    
    if (json['participants'] != null) {
      final participantsList = json['participants'] as List<dynamic>;
      for (final participant in participantsList) {
        if (participant is String) {
          participantIds.add(participant);
        } else if (participant is Map<String, dynamic>) {
          participantIds.add(participant['_id'] ?? participant['id'] ?? '');
          participantDetails.add(Participant.fromJson(participant));
        }
      }
    }

    // Handle lastMessage - it can be an ObjectId or a populated message object
    String? lastMessageContent;
    if (json['lastMessage'] != null) {
      if (json['lastMessage'] is String) {
        // It's just an ObjectId reference
        lastMessageContent = null;
      } else if (json['lastMessage'] is Map<String, dynamic>) {
        // It's a populated message object
        lastMessageContent = json['lastMessage']['content'];
      }
    }

    return Chat(
      id: json['_id'] ?? json['id'] ?? '',
      participants: participantIds,
      lastMessage: lastMessageContent,
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt']) 
          : null,
      isActive: json['isActive'] ?? true,
      unreadCount: json['unreadCount'] ?? 0,
      participantDetails: participantDetails,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => Message.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'isActive': isActive,
      'unreadCount': unreadCount,
    };
  }
}

class Participant {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;

  Participant({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  String get fullName => '$firstName $lastName';
}
