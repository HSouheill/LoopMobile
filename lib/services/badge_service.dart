import 'package:app_badge_plus/app_badge_plus.dart';

/// Service to manage app badge notifications
/// Works on both iOS and Android
class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  int _currentBadgeCount = 0;

  /// Update the app badge count
  /// [count] - The number to display on the badge (0 to clear badge)
  Future<void> updateBadgeCount(int count) async {
    try {
      // Check if badges are supported on this platform
      final isSupported = await AppBadgePlus.isSupported();
      if (!isSupported) {
        return;
      }

      // Ensure count is non-negative
      final badgeCount = count < 0 ? 0 : count;
      
      // Only update if the count has changed
      if (_currentBadgeCount != badgeCount) {
        _currentBadgeCount = badgeCount;
        
        // Update the badge (0 clears it)
        await AppBadgePlus.updateBadge(badgeCount);
      }
    } catch (e) {
      // Silently fail - badge updates are not critical
      // Some devices/emulators may not support badges
    }
  }

  /// Clear the app badge
  Future<void> clearBadge() async {
    await updateBadgeCount(0);
  }

  /// Get the current badge count
  int get currentBadgeCount => _currentBadgeCount;
}

