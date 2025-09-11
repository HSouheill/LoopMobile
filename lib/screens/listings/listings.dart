import 'package:flutter/material.dart';
import '../../widgets/search_and_categories_widget.dart';
import '../../widgets/featured_listings_widget.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  @override
  Widget build(BuildContext context) {
    // Sample data for Featured Listings
    final List<PropertyListing> featuredProperties = [
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Modern Family House with Garden',
        price: '\$750,000/Month',
        agentName: 'Sarah Johnson',
        location: 'Beverly Hills, CA',
        isFeatured: true,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Luxury Downtown Penthouse',
        price: '\$1,250,000',
        agentName: 'Michael Chen',
        location: 'Manhattan, NY',
        isFeatured: true,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1505843795480-5cfb3c03f6ff?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Elegant Victorian Home',
        price: '\$890,000',
        agentName: 'Emma Wilson',
        location: 'San Francisco, CA',
        isFeatured: true,
      ),
    ];

    // Sample data for New Listings
    final List<PropertyListing> newListings = [
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Contemporary Townhouse',
        price: '\$425,000',
        agentName: 'David Martinez',
        location: 'Austin, TX',
        isFeatured: false,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Cozy Suburban Home',
        price: '\$320,000',
        agentName: 'Lisa Thompson',
        location: 'Phoenix, AZ',
        isFeatured: false,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Modern City Loft',
        price: '\$520,000',
        agentName: 'Alex Rodriguez',
        location: 'Chicago, IL',
        isFeatured: false,
      ),
    ];

    // Sample data for Apartments
    final List<PropertyListing> apartments = [
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Luxury Studio Apartment',
        price: '\$2,800/Month',
        agentName: 'Jennifer Lee',
        location: 'Downtown Miami, FL',
        isFeatured: false,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: '2-Bedroom City View Apartment',
        price: '\$3,400/Month',
        agentName: 'Mark Johnson',
        location: 'Seattle, WA',
        isFeatured: false,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Spacious 3-Bedroom Apartment',
        price: '\$4,200/Month',
        agentName: 'Rachel Green',
        location: 'Boston, MA',
        isFeatured: false,
      ),
    ];

    // Sample data for Chalets
    final List<PropertyListing> chalets = [
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Mountain View Chalet',
        price: '\$1,850,000',
        agentName: 'Robert Alpine',
        location: 'Aspen, CO',
        isFeatured: false,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1511593358241-7eea1f3c84e5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Lakeside Luxury Chalet',
        price: '\$2,100,000',
        agentName: 'Maria Santos',
        location: 'Lake Tahoe, CA',
        isFeatured: false,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1520637836862-4d197d17c0a4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Cozy Forest Chalet',
        price: '\$950,000',
        agentName: 'Thomas Woods',
        location: 'Big Bear, CA',
        isFeatured: false,
      ),
    ];

    // Sample data for Commercial Buildings
    final List<PropertyListing> commercialBuildings = [
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Modern Office Building',
        price: '\$8,500,000',
        agentName: 'Corporate Realty',
        location: 'Financial District, NYC',
        isFeatured: false,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Retail Shopping Complex',
        price: '\$12,000,000',
        agentName: 'Commercial Group',
        location: 'Santa Monica, CA',
        isFeatured: false,
      ),
      PropertyListing(
        imageUrl:
            'https://images.unsplash.com/photo-1497366216548-37526070297c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Industrial Warehouse',
        price: '\$3,800,000',
        agentName: 'Industrial Properties',
        location: 'Houston, TX',
        isFeatured: false,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar Component
          const SearchAndCategoriesWidget(),

          // Featured Listings
          FeaturedListingsWidget(
            title: 'Featured Listings',
            listings: featuredProperties,
          ),

          // New Listings
          FeaturedListingsWidget(
            title: 'New Listings',
            listings: newListings,
          ),

          // Apartments
          FeaturedListingsWidget(
            title: 'Apartments',
            listings: apartments,
          ),

          // Chalets
          FeaturedListingsWidget(
            title: 'Chalets',
            listings: chalets,
          ),

          // Commercial Buildings
          FeaturedListingsWidget(
            title: 'Commercial Buildings',
            listings: commercialBuildings,
          ),
        ],
      ),
    );
  }
}
