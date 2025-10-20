class Favorite {
  final String id;
  final String favoritedObjectId;
  final String userId;
  final String table;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FavoriteObjectDetails objectDetails;

  Favorite({
    required this.id,
    required this.favoritedObjectId,
    required this.userId,
    required this.table,
    required this.createdAt,
    required this.updatedAt,
    required this.objectDetails,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['_id'] ?? '',
      favoritedObjectId: json['favoritedObjectId'] ?? '',
      userId: json['userId'] ?? '',
      table: json['table'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      objectDetails: FavoriteObjectDetails.fromJson(json['objectDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'favoritedObjectId': favoritedObjectId,
      'userId': userId,
      'table': table,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'objectDetails': objectDetails.toJson(),
    };
  }
}

class FavoriteObjectDetails {
  // Common fields
  final String? title;
  final String? description;
  final String? image;
  final String? location;
  
  // User-specific fields
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImage;
  
  // Listing-specific fields
  final int? price;
  final Map<String, dynamic>? locationDetails;
  final List<String>? images;
  
  // Job-specific fields
  final String? jobLocation;

  FavoriteObjectDetails({
    this.title,
    this.description,
    this.image,
    this.location,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImage,
    this.price,
    this.locationDetails,
    this.images,
    this.jobLocation,
  });

  factory FavoriteObjectDetails.fromJson(Map<String, dynamic> json) {
    // Handle location field - it can be either a String or a Map
    String? locationString;
    Map<String, dynamic>? locationMap;
    
    if (json['location'] != null) {
      if (json['location'] is String) {
        locationString = json['location'];
      } else if (json['location'] is Map<String, dynamic>) {
        locationMap = json['location'];
        // Extract city from location map for display
        locationString = locationMap?['city'];
      }
    }
    
    return FavoriteObjectDetails(
      title: json['title'],
      description: json['description'],
      image: json['image'],
      location: locationString,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      profileImage: json['profileImage'],
      price: json['price'],
      locationDetails: locationMap,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      jobLocation: locationString,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'location': locationDetails,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImage': profileImage,
      'price': price,
      'images': images,
    };
  }

  // Helper methods to get display information
  String get displayTitle {
    if (title != null) return title!;
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return 'Unknown Item';
  }

  String get displayDescription {
    if (description != null) return description!;
    if (email != null) return email!;
    return '';
  }

  String get displayLocation {
    if (location != null) return location!;
    if (locationDetails != null && locationDetails!['city'] != null) {
      return locationDetails!['city'];
    }
    if (jobLocation != null) return jobLocation!;
    return '';
  }

  String? get displayImage {
    return image ?? profileImage;
  }

  String get itemType {
    if (firstName != null) return 'User';
    if (price != null) return 'Listing';
    if (title != null && description != null && price == null) return 'Job';
    return 'Unknown';
  }
}

class FavoritesResponse {
  final List<Favorite> favorites;
  final PaginationInfo pagination;

  FavoritesResponse({
    required this.favorites,
    required this.pagination,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      favorites: (json['favorites'] as List<dynamic>?)
          ?.map((item) => Favorite.fromJson(item))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favorites': favorites.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalCount: json['totalCount'] ?? 0,
      limit: json['limit'] ?? 8,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalCount': totalCount,
      'limit': limit,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}
