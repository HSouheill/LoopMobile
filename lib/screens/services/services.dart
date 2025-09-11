import 'package:flutter/material.dart';
import '../../widgets/search_and_categories_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/recommended_agents_widget.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> sliderImages = [
      'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1556761175-b413da4baf72?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    ];

    // Featured Services data
    final List<Agent> featuredServices = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3182773/pexels-photo-3182773.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Premium Home Renovation',
        propertyCount: 0,
        location: 'Beirut, Lebanon',
        rating: 4.9,
        reviewCount: 234,
        customText: 'Full renovation services',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3861964/pexels-photo-3861964.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Elite Cleaning Solutions',
        propertyCount: 0,
        location: 'Jounieh, Mount Lebanon',
        rating: 4.8,
        reviewCount: 189,
        customText: 'Deep cleaning specialists',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/7567843/pexels-photo-7567843.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Smart Security Systems',
        propertyCount: 0,
        location: 'Hazmieh, Mount Lebanon',
        rating: 4.9,
        reviewCount: 156,
        customText: 'Advanced security solutions',
      ),
    ];

    // Top Rated Services data
    final List<Agent> topRatedServices = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/4792509/pexels-photo-4792509.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Master Electricians',
        propertyCount: 0,
        location: 'Beirut, Lebanon',
        rating: 5.0,
        reviewCount: 298,
        customText: 'Electrical installations',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/5691659/pexels-photo-5691659.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Pro Plumbing Services',
        propertyCount: 0,
        location: 'Dbayeh, Mount Lebanon',
        rating: 4.9,
        reviewCount: 267,
        customText: 'Emergency plumbing',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Garden Masters',
        propertyCount: 0,
        location: 'Antelias, Mount Lebanon',
        rating: 4.9,
        reviewCount: 178,
        customText: 'Landscaping & design',
      ),
    ];

    // Companies Services data
    final List<Agent> companiesServices = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3182773/pexels-photo-3182773.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Alpha Maintenance Co.',
        propertyCount: 0,
        location: 'Beirut, Lebanon',
        rating: 4.8,
        reviewCount: 152,
        customText: 'Electrical, plumbing',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3861964/pexels-photo-3861964.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'BrightClean Services',
        propertyCount: 0,
        location: 'Jounieh, Mount Lebanon',
        rating: 4.6,
        reviewCount: 89,
        customText: 'Deep Cleaning',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/7567843/pexels-photo-7567843.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'SecureGuard Systems',
        propertyCount: 0,
        location: 'Hazmieh, Mount Lebanon',
        rating: 4.7,
        reviewCount: 110,
        customText: 'CCTV',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/4792509/pexels-photo-4792509.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'TechFix Solutions',
        propertyCount: 0,
        location: 'Sin El Fil, Mount Lebanon',
        rating: 4.5,
        reviewCount: 98,
        customText: 'IT support & repair',
      ),
    ];

    // Individual Services data
    final List<Agent> individualServices = [
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3757941/pexels-photo-3757941.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Sam The Plumber',
        propertyCount: 0,
        location: 'Beirut, Lebanon',
        rating: 4.5,
        reviewCount: 42,
        customText: 'Plumbing, repairs',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/1680143/pexels-photo-1680143.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Lina Painter',
        propertyCount: 0,
        location: 'Jounieh, Mount Lebanon',
        rating: 4.6,
        reviewCount: 37,
        customText: 'Interior painting',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/3815587/pexels-photo-3815587.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Fadi Electric',
        propertyCount: 0,
        location: 'Hazmieh, Mount Lebanon',
        rating: 4.7,
        reviewCount: 58,
        customText: 'Electrical fixes',
      ),
      Agent(
        imageUrl:
            'https://images.pexels.com/photos/4792462/pexels-photo-4792462.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
        name: 'Maria Cleaner',
        propertyCount: 0,
        location: 'Dbayeh, Mount Lebanon',
        rating: 4.4,
        reviewCount: 31,
        customText: 'House cleaning',
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SearchAndCategoriesWidget(),
          const SizedBox(height: 10),
          ImageSliderWidget(imageUrls: sliderImages),
          const SizedBox(height: 20),

          // Explore Jobs Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/jobs');
                },
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007BFF), Color(0xFF0056b3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow: [], // Keeps it consistent with SupportCard (no shadow)
                  ),
                  child: const Center(
                    child: Text(
                      'Explore Jobs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Featured Services
          RecommendedAgentsWidget(
            title: 'Featured Services',
            agents: featuredServices,
            showPropertyCount: false,
          ),
          const SizedBox(height: 10),

          // Top Rated Services
          RecommendedAgentsWidget(
            title: 'Top Rated',
            agents: topRatedServices,
            showPropertyCount: false,
          ),
          const SizedBox(height: 10),

          // Companies Services
          RecommendedAgentsWidget(
            title: 'Companies',
            agents: companiesServices,
            showPropertyCount: false,
          ),
          const SizedBox(height: 10),

          // Individual Services
          RecommendedAgentsWidget(
            title: 'Individual Services',
            agents: individualServices,
            showPropertyCount: false,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
