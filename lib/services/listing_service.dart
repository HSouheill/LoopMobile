// Enhanced services/listing_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ListingService {
  static const String baseUrl = 'http://10.0.3.198:3000/api/listings';
  
  static Future<ListingsResponse> getFeaturedListings({int limit = 3}) async {
    try {
      final url = Uri.parse('$baseUrl/get-all?isFeatured=true&limit=$limit&sort=date_desc');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListingsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load featured listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching featured listings: $e');
    }
  }
  
  static Future<ListingsResponse> getNewListings({int limit = 3}) async {
    try {
      final url = Uri.parse('$baseUrl/get-all?limit=$limit&sort=date_desc');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListingsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load new listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching new listings: $e');
    }
  }
  
  static Future<ListingsResponse> getListingsByType({
    required String type,
    int limit = 3,
    String sort = 'date_desc',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/get-all?type=$type&limit=$limit&sort=$sort');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListingsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load $type listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching $type listings: $e');
    }
  }
  
  static Future<ListingsResponse> getAllListings({
    int page = 1,
    int limit = 10,
    bool? isFeatured,
    String? type,
    String? city,
    String? sort = 'date_desc',
    String? listingFor,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (sort != null) 'sort': sort,
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
        if (type != null) 'type': type,
        if (city != null) 'city': city,
        if (listingFor != null) 'listingFor': listingFor,
      };
      
      final uri = Uri.parse('$baseUrl/get-all').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListingsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching listings: $e');
    }
  }
}

enum ListingCategory {
  featured,
  newListings,
  apartments,
  chalets,
  commercial,
}

extension ListingCategoryExtension on ListingCategory {
  String get displayName {
    switch (this) {
      case ListingCategory.featured:
        return 'Featured Listings';
      case ListingCategory.newListings:
        return 'New Listings';
      case ListingCategory.apartments:
        return 'Apartments';
      case ListingCategory.chalets:
        return 'Chalets';
      case ListingCategory.commercial:
        return 'Commercial Buildings';
    }
  }
  
  String? get apiType {
    switch (this) {
      case ListingCategory.featured:
        return null; // Handled by isFeatured parameter
      case ListingCategory.newListings:
        return null; // Just sorted by date
      case ListingCategory.apartments:
        return 'apartment';
      case ListingCategory.chalets:
        return 'chalet';
      case ListingCategory.commercial:
        return 'commercial';
    }
  }
  
  String get routeName {
    switch (this) {
      case ListingCategory.featured:
        return '/featured-listings';
      case ListingCategory.newListings:
        return '/new-listings';
      case ListingCategory.apartments:
        return '/apartments';
      case ListingCategory.chalets:
        return '/chalets';
      case ListingCategory.commercial:
        return '/commercial';
    }
  }
}

class ListingsResponse {
  final List<PropertyListing> listings;
  final ListingMeta meta;
  
  ListingsResponse({
    required this.listings,
    required this.meta,
  });
  
  factory ListingsResponse.fromJson(Map<String, dynamic> json) {
    return ListingsResponse(
      listings: (json['listings'] as List)
          .map((listing) => PropertyListing.fromJson(listing))
          .toList(),
      meta: ListingMeta.fromJson(json['meta']),
    );
  }
}

class ListingMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;
  
  ListingMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
  
  factory ListingMeta.fromJson(Map<String, dynamic> json) {
    return ListingMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }
}

class PropertyListing {
  final String id;
  final String imageUrl;
  final String title;
  final String price;
  final String agentName;
  final String location;
  final bool isFeatured;
  final String? type;
  final String? listingFor;
  
  PropertyListing({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.agentName,
    required this.location,
    this.isFeatured = false,
    this.type,
    this.listingFor,
  });
  
  factory PropertyListing.fromJson(Map<String, dynamic> json) {
    // Handle images array - take first image or use placeholder
    String imageUrl = 'https://via.placeholder.com/300x200?text=No+Image';
    if (json['images'] != null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0].toString();
    }
    
    // Handle price formatting
    String priceStr = '\$0';
    if (json['price'] != null) {
      final price = json['price'];
      if (price is num) {
        priceStr = '\$${_formatNumber(price.toInt())}';
      } else {
        priceStr = price.toString();
      }
      // Add per month for rentals
      if (json['listingFor']?.toString().toLowerCase() == 'rent') {
        priceStr += '/Month';
      }
    }
    
    // Handle daily price for rentals
    if (json['dailyPrice'] != null && json['listingFor']?.toString().toLowerCase() == 'rent') {
      final dailyPrice = json['dailyPrice'];
      if (dailyPrice is num && dailyPrice > 0) {
        priceStr = '\$${_formatNumber(dailyPrice.toInt())}/Day';
      }
    }
    
    // Handle location
    String locationStr = 'Unknown Location';
    if (json['location'] != null) {
      final location = json['location'];
      if (location is Map<String, dynamic>) {
        final city = location['city']?.toString() ?? '';
        final country = location['country']?.toString() ?? '';
        locationStr = [city, country].where((s) => s.isNotEmpty).join(', ');
      } else {
        locationStr = location.toString();
      }
    }
    
    // Handle owner/agent name
    String agentName = 'Unknown Agent';
    if (json['owner'] != null) {
      final owner = json['owner'];
      if (owner is Map<String, dynamic>) {
        agentName = owner['username']?.toString() ?? 
                   owner['fullName']?.toString() ?? 
                   owner['email']?.toString() ?? 
                   'Unknown Agent';
      }
    }
    
    return PropertyListing(
      id: json['_id']?.toString() ?? '',
      imageUrl: imageUrl,
      title: json['title']?.toString() ?? 'Untitled Property',
      price: priceStr,
      agentName: agentName,
      location: locationStr,
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 'true',
      type: json['type']?.toString(),
      listingFor: json['listingFor']?.toString(),
    );
  }
  
  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else {
      return number.toString();
    }
  }
}