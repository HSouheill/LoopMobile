// lib/utils/verification_guard.dart
//
// Central gate for actions that require an admin-approved account: creating or
// editing listings, jobs, and services. The backend enforces this too (returns
// 403 ACCOUNT_PENDING / ACCOUNT_REJECTED via the requireVerified middleware);
// this just gives the user a clear message up front instead of a generic error.
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class VerificationGuard {
  /// Returns true if the current user may create/edit content.
  ///
  /// When blocked, shows an explanatory SnackBar and returns false. Refreshes
  /// the user from the server first so a freshly-approved account isn't held
  /// back by stale local data.
  static Future<bool> ensureCanManageContent(BuildContext context) async {
    // Pull the latest status; fall back to the cached user on network failure.
    await AuthService.refreshCurrentUser();

    // Compute the block message (if any) before touching `context` again, so the
    // only BuildContext use sits behind a single mounted check.
    final user = AuthService.currentUser;
    String? blockMessage;

    if (user == null) {
      blockMessage = 'Please sign in to continue.';
    } else if (user.isApproved) {
      return true;
    } else if (user.isRejected) {
      final reason = user.rejectionReason;
      blockMessage = (reason != null && reason.isNotEmpty)
          ? 'Your account was rejected: $reason'
          : 'Your account was rejected, so you can\'t post or edit listings, '
              'jobs, or services. Please contact support.';
    } else {
      // pending / unknown
      blockMessage =
          'Your account is under review. You\'ll be able to post or edit '
          'listings, jobs, and services once an admin approves it.';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(blockMessage),
          duration: const Duration(seconds: 5),
        ),
      );
    }
    return false;
  }
}
