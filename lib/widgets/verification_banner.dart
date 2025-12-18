import 'package:flutter/material.dart';

class VerificationBanner extends StatelessWidget {
  final Map<String, dynamic>? agentInfo;

  const VerificationBanner({
    super.key,
    this.agentInfo,
  });

  String? _getVerificationStatus() {
    if (agentInfo == null || agentInfo!['user'] == null) {
      return null;
    }
    
    // Try different possible field names for verification status
    final user = agentInfo!['user'];
    return user['verificationStatus'] ?? 
           user['verification_status'];
  }

  @override
  Widget build(BuildContext context) {
    final status = _getVerificationStatus();
    
    // Don't show banner if status is null, empty, or 'approved'
    if (status == null || 
        status.toString().isEmpty || 
        status.toString().toLowerCase() == 'approved') {
      return const SizedBox.shrink();
    }

    final statusLower = status.toString().toLowerCase();
    
    // Determine banner color and message
    Color? backgroundColor;
    LinearGradient? gradient;
    String message;
    IconData icon;

    if (statusLower == 'pending') {
      // Blue gradient matching button colors
      gradient = const LinearGradient(
        colors: [
          Color.fromARGB(255, 103, 155, 218),
          Color.fromARGB(255, 69, 100, 201),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
      message = 'Your verification is pending. We will review your profile shortly.';
      icon = Icons.pending_outlined;
    } else if (statusLower == 'rejected') {
      // Red color
      backgroundColor = Colors.red;
      message = 'Your verification has been rejected. Please update your profile and resubmit.';
      icon = Icons.cancel_outlined;
    } else {
      // Unknown status, don't show
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: (gradient != null 
                ? const Color.fromARGB(255, 69, 100, 201)
                : Colors.red).withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

