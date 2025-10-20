import 'package:flutter/material.dart';
import '../../widgets/search_only_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/dynamic_services_widget.dart';
import '../../services/service_service.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> sliderImages = [
      'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1556761175-b413da4baf72?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    ];


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SearchOnlyWidget(),
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

          // Top Rated Services
          const DynamicServicesWidget(
            category: ServiceCategory.topRated,
            showSeeAll: true,
          ),

          // Company Services
          const DynamicServicesWidget(
            category: ServiceCategory.companies,
            showSeeAll: true,
          ),

          // Individual Services
          const DynamicServicesWidget(
            category: ServiceCategory.individual,
            showSeeAll: true,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
