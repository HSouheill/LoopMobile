// Enhanced services/listing_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

class ListingService {
  static final String baseUrl = '${Environment.apiUrl}listings';

  static Future<ListingsResponse> getFeaturedListings({int limit = 3}) async {
    try {
      final url = Uri.parse(
          '$baseUrl/get-all?isFeatured=true&limit=$limit&sort=date_desc');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListingsResponse.fromJson(data);
      } else {
        throw Exception(
            'Failed to load featured listings: ${response.statusCode}');
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
      final url =
          Uri.parse('$baseUrl/get-all?type=$type&limit=$limit&sort=$sort');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListingsResponse.fromJson(data);
      } else {
        throw Exception(
            'Failed to load $type listings: ${response.statusCode}');
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

      final uri =
          Uri.parse('$baseUrl/get-all').replace(queryParameters: queryParams);
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

  static Future<ListingsResponse> searchListings({
    String query = '',
    String? category,
    int page = 1,
    int limit = 20,
    String sort = 'score',
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        if (category != null) 'type': category,
      };


      // Add filter parameters
      if (filters != null) {
        if (filters['listingFor'] != null) {
          queryParams['listingFor'] = filters['listingFor'].toString();
        }
        if (filters['city'] != null) {
          queryParams['city'] = filters['city'].toString();
        }
        if (filters['minPrice'] != null) {
          queryParams['minPrice'] = filters['minPrice'].toString();
        }
        if (filters['maxPrice'] != null) {
          queryParams['maxPrice'] = filters['maxPrice'].toString();
        }
        if (filters['condition'] != null) {
          queryParams['condition'] = filters['condition'].toString();
        }
        // Add amenity filters
        final amenityFilters = <String>[];
        if (filters['parking'] == true) amenityFilters.add('parking');
        if (filters['elevator'] == true) amenityFilters.add('elevator');
        if (filters['pool'] == true) amenityFilters.add('sharedPool');
        if (filters['garden'] == true) amenityFilters.add('garden');
        if (filters['security'] == true) amenityFilters.add('security');
        if (filters['furnished'] == true) amenityFilters.add('furnished');

        if (amenityFilters.isNotEmpty) {
          queryParams['amenities'] = amenityFilters.join(',');
        }
      }

      final uri = Uri.parse('${Environment.apiUrl}listings/search')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListingsResponse.fromJson(data);
      } else {
        throw Exception('Failed to search listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching listings: $e');
    }
  }

  // Get agent's listings with status filter
  static Future<ListingsResponse> getMyListings({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final url = Uri.parse('${Environment.apiUrl}listings/my-listings')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListingsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load agent listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agent listings: $e');
    }
  }

  // Get single listing details
  static Future<PropertyListing> getListingDetails(String listingId) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}listings/$listingId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PropertyListing.fromJson(data);
      } else {
        throw Exception('Failed to load listing details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching listing details: $e');
    }
  }

  // Create a new listing
  static Future<bool> createListing(Map<String, dynamic> listingData) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}listings/create');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode(listingData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create listing: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating listing: $e');
      return false;
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
  final String? status;
  // Extended fields for single listing page
  final List<String>? images;
  final String? currency;
  final num? priceValue;
  final DateTime? createdAt;
  final String? description;
  final List<String>? amenityList;
  final num? size;
  final int? bedrooms;
  final int? bathrooms;
  final int? floor;
  final String? condition;
  final int? buildingAge;
  final String? papers;
  final DateTime? availableFrom;
  // Owner information
  final String? ownerFirstName;
  final String? ownerLastName;
  final String? ownerEmail;
  final String? ownerPhone;
  // Contact information
  final String? contactPhone;
  final String? contactEmail;

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
    this.status,
    this.images,
    this.currency,
    this.priceValue,
    this.createdAt,
    this.description,
    this.amenityList,
    this.size,
    this.bedrooms,
    this.bathrooms,
    this.floor,
    this.condition,
    this.buildingAge,
    this.papers,
    this.availableFrom,
    this.ownerFirstName,
    this.ownerLastName,
    this.ownerEmail,
    this.ownerPhone,
    this.contactPhone,
    this.contactEmail,
  });

  // Helper method to build full image URL
  static String _buildImageUrl(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'https://via.placeholder.com/300x200?text=No+Image';
    }
    
    // If it's already a full URL, return as is
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }
    
    // Build full URL - merge with API URL
    return '${Environment.apiUrl}assets/$filename';
  }

  factory PropertyListing.fromJson(Map<String, dynamic> json) {
    // Handle images array - take first image or use placeholder
    String imageUrl = 'https://via.placeholder.com/300x200?text=No+Image';
    List<String>? images;
    if (json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      final rawImages = (json['images'] as List).map((e) => e.toString()).toList();
      // Build full URLs for all images
      images = rawImages.map((img) => _buildImageUrl(img)).toList();
      imageUrl = images.first;
    }

    // Handle price formatting with payment frequency
    String priceStr = '\$0';
    num? priceValue;
    String? currency;
    
    if (json['price'] != null) {
      final price = json['price'];
      if (price is num) {
        priceValue = price;
        priceStr = '\$${_formatNumber(price.toInt())}';
        
        // Add frequency suffix based on paymentFrequency field
        final paymentFrequency = json['paymentFrequency']?.toString().toLowerCase();
        final listingFor = json['listingFor']?.toString().toLowerCase();
        
        if (listingFor == 'rent') {
          // For rent, show the frequency
          if (paymentFrequency == 'daily') {
            priceStr += '/Day';
          } else if (paymentFrequency == 'yearly') {
            priceStr += '/Year';
          } else {
            // Default to monthly for rent
            priceStr += '/Month';
          }
        }
        // For sale, just show the price with no suffix
      } else {
        priceStr = price.toString();
      }
    }
    
    if (json['currency'] != null) {
      currency = json['currency'].toString();
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

    // Handle owner/agent name and owner information
    String agentName = 'Unknown Agent';
    String? ownerFirstName;
    String? ownerLastName;
    String? ownerEmail;
    String? ownerPhone;

    if (json['owner'] != null) {
      final owner = json['owner'];
      if (owner is Map<String, dynamic>) {
        ownerFirstName = owner['firstName']?.toString();
        ownerLastName = owner['lastName']?.toString();
        ownerEmail = owner['email']?.toString();
        ownerPhone = owner['phone']?.toString();

        // Set agent name to full name if available, otherwise fallback to email
        if (ownerFirstName != null && ownerLastName != null) {
          agentName = '$ownerFirstName $ownerLastName';
        } else if (ownerFirstName != null) {
          agentName = ownerFirstName;
        } else if (ownerEmail != null) {
          agentName = ownerEmail;
        } else {
          agentName = 'Unknown Agent';
        }
      }
    }

    // Handle contact information
    String? contactPhone = json['contactPhone']?.toString();
    String? contactEmail = json['contactEmail']?.toString();

    // Parse optional fields for single listing page
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.tryParse(json['createdAt'].toString());
      } catch (_) {}
    }
    DateTime? availableFrom;
    if (json['availableFrom'] != null) {
      try {
        availableFrom = DateTime.tryParse(json['availableFrom'].toString());
      } catch (_) {}
    }
    String? description = json['description']?.toString();
    List<String>? amenityList;
    final amenities = json['amenities'] ?? json['amenityList'];
    if (amenities is List) {
      amenityList = amenities.map((e) => e.toString()).toList();
    } else if (amenities is Map<String, dynamic>) {
      // Handle amenities object with boolean values
      amenityList = amenities.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
    }
    num? size;
    if (json['size'] is num) size = json['size'];
    int? bedrooms;
    if (json['bedrooms'] is num) bedrooms = (json['bedrooms'] as num).toInt();
    int? bathrooms;
    if (json['bathrooms'] is num)
      bathrooms = (json['bathrooms'] as num).toInt();
    int? floor;
    if (json['floor'] is num) floor = (json['floor'] as num).toInt();
    String? condition = json['condition']?.toString();
    int? buildingAge;
    if (json['buildingAge'] is num)
      buildingAge = (json['buildingAge'] as num).toInt();
    String? papers = json['papers']?.toString();

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
      status: json['status']?.toString(),
      images: images,
      currency: currency,
      priceValue: priceValue,
      createdAt: createdAt,
      description: description,
      amenityList: amenityList,
      size: size,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      floor: floor,
      condition: condition,
      buildingAge: buildingAge,
      papers: papers,
      availableFrom: availableFrom,
      ownerFirstName: ownerFirstName,
      ownerLastName: ownerLastName,
      ownerEmail: ownerEmail,
      ownerPhone: ownerPhone,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
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
