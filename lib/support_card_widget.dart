import 'package:flutter/material.dart';

class SupportCardWidget extends StatelessWidget {
  const SupportCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.transparent, // Makes the background fully transparent
        borderRadius: BorderRadius.circular(0.0), // Removes border radius, effectively removing borders
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Facing Legal Issues Or Other Concerns Related To Your Property? Our Expert Support Team Is Just A Message Away Ready To Assist You',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              // Add your navigation or action here
              // Example: Navigator.pushNamed(context, '/support');
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
                boxShadow: [], // Removes the shadows
              ),
              child: const Center(
                child: Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
