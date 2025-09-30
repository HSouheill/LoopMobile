import 'package:flutter/material.dart';
import '../../../widgets/profile_widgets/dynamic_gradient_button.dart';

class AddSocialAccountWidget extends StatelessWidget {
  final Function(String name, String url)? onSubmit;

  const AddSocialAccountWidget({Key? key, this.onSubmit}) : super(key: key);

  void _showAddSocialDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    fontSize: 14, // Input text size
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'example: Facebook',
                    hintStyle: const TextStyle(
                      fontSize: 14, // Hint text size
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8), // Space between hint and divider
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey), // Normal divider color
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF0048FF)), // Divider when focused
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'add social account URL',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0048FF)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DynamicGradientButton(
              buttonText: 'Submit',
              onTap: () {
                if (onSubmit != null) {
                  onSubmit!(nameController.text, urlController.text);
                }
                Navigator.of(context).pop();
              },
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              useGradient: true,
              textColor: const Color(0xFFFFFFFF),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showAddSocialDialog(context),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5F5F5), // background color
                    border: Border.all(
                      color: const Color(0xFF0048FF), // border color
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(1),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF0048FF),
                    size: 14, // icon color
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add Social Account URL',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
