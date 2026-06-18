// Import PropertyListing from listing_service.dart
import '../services/listing_service.dart';

/// Parses [raw] into a list of [T] using [fromItem]. Anything that isn't a
/// list yields an empty list, and any single entry that fails to parse is
/// skipped — so malformed nested data can never throw out of a model's fromJson.
List<T> _parseList<T>(dynamic raw, T Function(dynamic item) fromItem) {
  if (raw is! List) return <T>[];
  final out = <T>[];
  for (final item in raw) {
    try {
      out.add(fromItem(item));
    } catch (_) {
      // Skip the bad entry rather than failing the whole parse.
    }
  }
  return out;
}

class Review {
  final String id;
  final String reviewedObjectId;
  final String userId;
  final String table;
  final String comment;
  final int rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userName;
  final String userProfileImage;

  Review({
    required this.id,
    required this.reviewedObjectId,
    required this.userId,
    required this.table,
    required this.comment,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userProfileImage,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id']?.toString() ?? '',
      reviewedObjectId: json['reviewedObjectId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      table: json['table']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toInt(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      userName: json['userName']?.toString() ?? '',
      userProfileImage: json['userProfileImage']?.toString() ?? '',
    );
  }

  // Helper method to format date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}

class SocialLink {
  final String name;
  final String link;
  final String id;

  SocialLink({
    required this.name,
    required this.link,
    required this.id,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      name: json['name']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
    );
  }
}

class AgentWithListingsAndReviews {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final bool isFeatured;
  final String? description;
  final String? city;
  final String? district;
  final String? governance;
  final String? country;
  final double averageRating;
  final int reviewCount;
  final int propertyCount;
  final List<Review> reviews;
  final List<PropertyListing> listings;
  final List<SocialLink> socialLinks;

  AgentWithListingsAndReviews({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    required this.isFeatured,
    this.description,
    this.city,
    this.district,
    this.governance,
    this.country,
    required this.averageRating,
    required this.reviewCount,
    required this.propertyCount,
    required this.reviews,
    required this.listings,
    required this.socialLinks,
  });

  factory AgentWithListingsAndReviews.fromJson(Map<String, dynamic> json) {
    return AgentWithListingsAndReviews(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 'true',
      description: json['description']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      governance: json['governance']?.toString(),
      country: json['country']?.toString(),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
      propertyCount: (json['propertyCount'] ?? 0).toInt(),
      // Each nested list is parsed defensively: a non-list value, or a single
      // malformed entry, is skipped rather than thrown so it can never take down
      // the whole agent page.
      reviews: _parseList<Review>(
        json['reviews'],
        (item) => Review.fromJson(item as Map<String, dynamic>),
      ),
      listings: _parseList<PropertyListing>(
        json['listings'],
        (item) {
          // The agent API often returns listings without a populated owner object.
          // Inject the agent's own data so SingleListingPage can show their picture.
          final listingMap = Map<String, dynamic>.from(item as Map<String, dynamic>);
          final existingOwner = listingMap['owner'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(listingMap['owner'] as Map<String, dynamic>)
              : <String, dynamic>{};
          if (existingOwner['profileImage'] == null) {
            existingOwner['_id'] ??= json['_id'];
            existingOwner['firstName'] ??= json['firstName'];
            existingOwner['lastName'] ??= json['lastName'];
            existingOwner['email'] ??= json['email'];
            existingOwner['phone'] ??= json['phone'];
            existingOwner['profileImage'] = json['profileImage'];
            listingMap['owner'] = existingOwner;
          }
          return PropertyListing.fromJson(listingMap);
        },
      ),
      socialLinks: _parseList<SocialLink>(
        json['socialLinks'],
        (item) => SocialLink.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  String get fullName => '$firstName $lastName';
  String get imageUrl => profileImage ?? '';
  String get customText => description ?? '';
}