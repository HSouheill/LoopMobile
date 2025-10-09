import 'package:flutter/material.dart';
import '../../../models/my_service.dart';
import '../../../services/service_service.dart';
import '../../../widgets/profile_widgets/dynamic_gradient_button.dart';

class MyServicesWidget extends StatefulWidget {
  const MyServicesWidget({super.key});

  @override
  State<MyServicesWidget> createState() => _MyServicesWidgetState();
}

class _MyServicesWidgetState extends State<MyServicesWidget> {
  List<MyService> services = [];
  bool isLoading = true;
  bool showAll = false;
  int currentPage = 1;
  int totalPages = 1;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        currentPage++;
      });
    }

    try {
      final response = await ServiceService.getMyServices(
        page: currentPage,
        limit: 20,
      );

      setState(() {
        if (loadMore) {
          services.addAll(response.services);
        } else {
          services = response.services;
        }
        totalPages = response.meta.pages;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshServices() async {
    setState(() {
      currentPage = 1;
      showAll = false;
    });
    await _loadServices();
  }

  void _toggleShowAll() {
    setState(() {
      showAll = !showAll;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null && services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshServices,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.business_center_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No services found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add your first service to get started',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Determine which services to show
    final servicesToShow = showAll ? services : services.take(3).toList();
    final hasMoreServices = services.length > 3;

    return Column(
      children: [
        // Services list
        ...servicesToShow.map((service) => MyServiceCard(
          service: service,
          onEdit: () {
            // Navigate to edit service
            Navigator.pushNamed(context, '/edit-my-service', arguments: service.id);
          },
          onDelete: () {
            _showDeleteConfirmation(service);
          },
          onBoost: () {
            // Handle boost functionality
            _showBoostDialog(service);
          },
        )),

        // Show All / Show Less button
        if (hasMoreServices) ...[
          const SizedBox(height: 16),
          Center(
            child: DynamicGradientButton(
              buttonText: showAll ? 'Show Less' : 'See All',
              onTap: _toggleShowAll,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              textSize: 14,
            ),
          ),
        ],

        // Load more button (if there are more pages and showing all)
        if (showAll && currentPage < totalPages) ...[
          const SizedBox(height: 16),
          Center(
            child: DynamicGradientButton(
              buttonText: 'Load More',
              onTap: () => _loadServices(loadMore: true),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              textSize: 14,
              useGradient: false,
              backgroundColor: const Color(0xFFF9FBFF),
              borderColor: const Color(0xFF0048FF),
              borderWidth: 1.0,
              textColor: const Color(0xFF0048FF),
            ),
          ),
        ],
      ],
    );
  }

  void _showDeleteConfirmation(MyService service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Service'),
          content: Text('Are you sure you want to delete "${service.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement delete service API call
                _refreshServices();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showBoostDialog(MyService service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Boost Service'),
          content: Text('Boost "${service.title}" to get more visibility?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement boost service functionality
              },
              child: const Text('Boost'),
            ),
          ],
        );
      },
    );
  }
}

class MyServiceCard extends StatefulWidget {
  final MyService service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onBoost;

  const MyServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
    required this.onBoost,
  });

  @override
  State<MyServiceCard> createState() => _MyServiceCardState();
}

class _MyServiceCardState extends State<MyServiceCard> {
  bool boostPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
      child: Column(
        children: [
          // First row: service title + rating/views
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.service.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.service.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row: image + buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.service.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.business, color: Colors.white),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Buttons
              Expanded(
                child: boostPressed
                    ? Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: DynamicGradientButton(
                                buttonText: 'Cancel',
                                onTap: () {
                                  setState(() {
                                    boostPressed = false;
                                  });
                                },
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                useGradient: false,
                                backgroundColor: const Color(0xFFF9FBFF),
                                borderColor: const Color(0xFFEA4435),
                                borderWidth: 1.0,
                                textColor: const Color(0xFFEA4435),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: DynamicGradientButton(
                                buttonText: 'Promote',
                                onTap: widget.onBoost,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Sold',
                                    onTap: () {
                                      // TODO: Implement sold functionality
                                    },
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    useGradient: false,
                                    backgroundColor: const Color(0xFFF9FBFF),
                                    borderColor: const Color(0xFF0048FF),
                                    borderWidth: 1.0,
                                    textColor: const Color(0xFF1E1E1E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Delete',
                                    onTap: widget.onDelete,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    useGradient: false,
                                    backgroundColor: const Color(0xFFF9FBFF),
                                    borderColor: const Color(0xFFEA4435),
                                    borderWidth: 1.0,
                                    textColor: const Color(0xFFEA4435),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Boost',
                                    onTap: () {
                                      setState(() {
                                        boostPressed = true;
                                      });
                                    },
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Edit',
                                    onTap: widget.onEdit,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
