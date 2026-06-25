import 'package:flutter/material.dart';
import '../../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../../models/my_service.dart';
import '../../../services/service_service.dart';

class EditMyService extends StatefulWidget {
  const EditMyService({super.key});

  @override
  State<EditMyService> createState() => _EditMyServiceState();
}

class _EditMyServiceState extends State<EditMyService> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescriptionController =
      TextEditingController();
  
  MyService? service;
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isLoading) {
      _loadServiceData();
    }
  }

  Future<void> _loadServiceData() async {
    try {
      // Get service data from route arguments
      final arguments = ModalRoute.of(context)?.settings.arguments;
      
      if (arguments == null) {
        setState(() {
          errorMessage = 'Service data not provided';
          isLoading = false;
        });
        return;
      }

      if (arguments is! MyService) {
        setState(() {
          errorMessage = 'Invalid service data type: ${arguments.runtimeType}';
          isLoading = false;
        });
        return;
      }

      // Set the service data and populate the form fields
      setState(() {
        service = arguments;
        _serviceNameController.text = arguments.title;
        _serviceDescriptionController.text = arguments.subtitle;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading service: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _saveService() async {
    if (_serviceNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a service name')),
      );
      return;
    }

    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service data not available')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final serviceData = {
        'title': _serviceNameController.text.trim(),
        'subtitle': _serviceDescriptionController.text.trim(),
      };

      final result = await ServiceService.editService(service!.id, serviceData);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate successful update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to update service')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // disable default back button
          flexibleSpace: Stack(
            children: [
              // ✅ Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/dashboard_background.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ✅ Custom back button
              Positioned(
                top: 20,
                left: 16,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF0048FF),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF0048FF),
                        size: 14,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ Body content
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading service',
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
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Row 1: Service image + input field (removed edit icon as requested)
                      Row(
                        children: [
                          // Service image (no edit icon)
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: service?.imageUrl != null
                                ? NetworkImage(service!.imageUrl)
                                : const AssetImage("assets/defaultProfileImage.png") as ImageProvider,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _serviceNameController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'Edit service name',
                                hintStyle: TextStyle(
                                  color: Color(0xFF0048FF),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF0048FF)),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF0048FF)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF0048FF), width: 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Row 2: TextArea
                      TextField(
                        controller: _serviceDescriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Edit service description',
                          hintStyle: TextStyle(
                            color: Color(0xFF0048FF),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0048FF)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0048FF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0048FF), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Row 3: Centered button
                      Center(
                        child: DynamicGradientButton(
                          buttonText: isSaving ? 'Saving...' : 'Update Service',
                          onTap: isSaving ? null : _saveService,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 17, vertical: 5.5),
                          textSize: 14.0,
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}