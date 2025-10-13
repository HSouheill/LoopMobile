class BlockedUser {
  final String id;
  final String blockerId;
  final String blockedId;
  final String? reason;
  final DateTime blockedAt;
  final User? blockedUser;

  BlockedUser({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    this.reason,
    required this.blockedAt,
    this.blockedUser,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    // Handle blocker field - it can be an ObjectId or populated user object
    String blockerId = '';
    if (json['blocker'] != null) {
      if (json['blocker'] is String) {
        blockerId = json['blocker'];
      } else if (json['blocker'] is Map<String, dynamic>) {
        blockerId = json['blocker']['_id'] ?? json['blocker']['id'] ?? '';
      }
    }

    // Handle blocked field - it can be an ObjectId or populated user object
    String blockedId = '';
    User? blockedUser;
    if (json['blocked'] != null) {
      if (json['blocked'] is String) {
        blockedId = json['blocked'];
      } else if (json['blocked'] is Map<String, dynamic>) {
        blockedId = json['blocked']['_id'] ?? json['blocked']['id'] ?? '';
        blockedUser = User.fromJson(json['blocked']);
      }
    }

    return BlockedUser(
      id: json['_id'] ?? json['id'] ?? '',
      blockerId: blockerId,
      blockedId: blockedId,
      reason: json['reason'],
      blockedAt: json['blockedAt'] != null 
          ? DateTime.parse(json['blockedAt']) 
          : DateTime.now(),
      blockedUser: blockedUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blocker': blockerId,
      'blocked': blockedId,
      'reason': reason,
      'blockedAt': blockedAt.toIso8601String(),
    };
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? email;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
      email: json['email'],
    );
  }

  String get fullName => '$firstName $lastName';
}
