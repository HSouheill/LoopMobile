import 'package:flutter/material.dart';
import 'package:loopflutter/widgets/profile_widgets/dynamic_gradient_button.dart';

class AddNewAgentScreen extends StatefulWidget {
  const AddNewAgentScreen({super.key});

  @override
  State<AddNewAgentScreen> createState() => _AddNewAgentScreenState();
}

class _AddNewAgentScreenState extends State<AddNewAgentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Custom gradient AppBar
      backgroundColor: const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          Container(
            height: 75,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.018, 1.3934),
                radius: 1.0,
                colors: [
                  Color(0xFF82A6FF),
                  Color(0xFF487CFF),
                  Color(0xFF3770FF),
                  Color(0xFF0048FF),
                ],
                stops: [0.0, 0.3221, 0.7212, 1.0],
              ),
            ),
          ),

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
                    size: 16,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),

          // 🏷️ App bar title
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Add New Agent",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 95, left: 16, right: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username input
                  _UnderlineTextField(
                    hintText: 'Enter Username',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 18),
                  // Password input
                  _UnderlineTextField(
                    hintText: 'Enter Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Page Access',
                    style: TextStyle(
                      color: Color(0xFF1D1D1D),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _AccessItem(label: 'Overview'),
                  _AccessItem(label: 'User Management'),
                  _AccessItem(label: 'Agent Management'),
                  _AccessItem(label: 'Service Provider Management'),
                  _AccessItem(label: 'Listing Management', initialValue: true),
                  _AccessItem(label: 'Bills & Payments'),
                  _AccessItem(label: 'CMS Dashboard'),
                  _AccessItem(label: 'Roles & Permissions'),
                  _AccessItem(label: 'Chat', initialValue: true),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel button (outlined)
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: const Color(0xFF0048FF), width: 1.5),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                foregroundColor: const Color(0xFF1E1E1E),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        // Add button (gradient)
                        Expanded(
                          child: DynamicGradientButton(
                            buttonText: 'Add',
                            onTap: () {},
                            padding: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 7),
                            textSize: 18, // optional
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnderlineTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const _UnderlineTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF0048FF), size: 20),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9AA3AF)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0048FF), width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0048FF), width: 1.4),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0048FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _AccessItem extends StatefulWidget {
  final String label;
  final bool initialValue;

  const _AccessItem({
    Key? key,
    required this.label,
    this.initialValue = false,
  }) : super(key: key);

  @override
  State<_AccessItem> createState() => _AccessItemState();
}

class _AccessItemState extends State<_AccessItem> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 18),
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isChecked,
              onChanged: (v) => setState(() => isChecked = v ?? false),
              activeColor: const Color(0xFF34C759),
              checkColor: Colors.white,
              side: const BorderSide(color: Color(0xFF34C759), width: 1.4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Color(0xFF1D1D1D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
