import 'package:flutter/material.dart';
import '../../../widgets/profile_widgets/dynamic_gradient_button.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescriptionController =
      TextEditingController();

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
                    image: AssetImage("assets/serverProviderBackground.png"),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row 1: Circular image + edit icon + input field
            Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage("assets/defaultProfileImage.png"),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0048FF),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _serviceNameController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Enter service name',
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
                hintText: 'Enter service description',
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
                buttonText: 'Add Service', // 👈 updated
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 5.5),
                textSize: 14.0,
                onTap: () {
                  // ✅ Add service action
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
