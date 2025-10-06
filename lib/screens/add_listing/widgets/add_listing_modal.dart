import 'package:flutter/material.dart';

class AddListingModal extends StatelessWidget {
  const AddListingModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Listing',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildModalOption(
                  icon: Icons.location_city,
                  title: 'Add New Building',
                  bgColor: Colors.orange[50],
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/add-listing');
                  },
                ),
                const SizedBox(height: 15),
                _buildModalOption(
                  icon: Icons.terrain,
                  title: 'Add New Land',
                  bgColor: Colors.green[50],
                  iconColor: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/add-land');
                  },
                ),
                const SizedBox(height: 15),
                _buildModalOption(
                  icon: Icons.business,
                  title: 'Add New Property',
                  bgColor: Colors.blue[50],
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/add-property');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build modal options
  Widget _buildModalOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? bgColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor ?? Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
