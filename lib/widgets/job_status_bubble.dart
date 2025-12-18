import 'package:flutter/material.dart';

class JobStatusBubble extends StatelessWidget {
  final String? status;
  final bool isSmall; // If true, shows small bubble; if false, shows full bubble

  const JobStatusBubble({
    super.key,
    this.status,
    this.isSmall = false,
  });

  String? _getStatus() {
    if (status == null || status!.isEmpty) {
      return null;
    }
    return status!.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusLower = _getStatus();
    
    // Don't show if status is null or empty
    if (statusLower == null) {
      return const SizedBox.shrink();
    }

    // For small bubbles, only show if pending or rejected
    if (isSmall && statusLower != 'pending' && statusLower != 'rejected') {
      return const SizedBox.shrink();
    }

    // Determine colors and text
    Color? backgroundColor;
    LinearGradient? gradient;
    String statusText;
    Color textColor = Colors.white;

    switch (statusLower) {
      case 'pending':
        // Gradient matching "post new jobs" button
        gradient = const LinearGradient(
          colors: [
            Color.fromARGB(255, 103, 155, 218),
            Color.fromARGB(255, 69, 100, 201),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        statusText = 'Pending';
        break;
      case 'rejected':
        backgroundColor = Colors.red;
        statusText = 'Rejected';
        break;
      case 'approved':
        backgroundColor = Colors.green;
        statusText = 'Approved';
        break;
      default:
        return const SizedBox.shrink();
    }

    if (isSmall) {
      // Small bubble for dashboard
      return Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: textColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      // Full bubble for my_jobs_page
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (gradient != null 
                  ? const Color.fromARGB(255, 69, 100, 201)
                  : backgroundColor ?? Colors.grey).withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(statusLower),
              color: textColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Status: $statusText',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'approved':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }
}

