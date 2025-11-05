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
      print('BadgeService: isSupported() returned: $isSupported');
      
      if (!isSupported) {
        print('BadgeService: Badges are not supported on this device/launcher');
        print('BadgeService: This is likely because your device/launcher does not support app icon badges');
        print('BadgeService: Supported devices: Samsung, Huawei, Oppo, Vivo, Xiaomi, OnePlus, etc.');
        return;
      }

      // Ensure count is non-negative
      final badgeCount = count < 0 ? 0 : count;
      
      print('BadgeService: Attempting to update badge to $badgeCount (current: $_currentBadgeCount)');
      
      // Always update badge, even if count hasn't changed (for Android compatibility)
      // Some Android launchers need the badge to be refreshed
      _currentBadgeCount = badgeCount;
      
      // Update the badge (0 clears it)
      await AppBadgePlus.updateBadge(badgeCount);
      print('BadgeService: Successfully called updateBadge($badgeCount)');
      print('BadgeService: If badge does not appear, check:');
      print('BadgeService: 1. Device/launcher supports badges (Samsung, Huawei, Oppo, Vivo, Xiaomi)');
      print('BadgeService: 2. App has notification permissions enabled');
      print('BadgeService: 3. Launcher has badge notifications enabled in settings');
    } catch (e, stackTrace) {
      print('BadgeService: Error updating badge: $e');
      print('BadgeService: Stack trace: $stackTrace');
      // Don't throw - badge updates are not critical
      // Some devices/emulators may not support badges
    }
  }

  /// Clear the app badge
  Future<void> clearBadge() async {
    await updateBadgeCount(0);
  }

  /// Get the current badge count
  int get currentBadgeCount => _currentBadgeCount;

  /// Check if badges are supported and test the badge
  /// Returns true if supported, false otherwise
  Future<bool> testBadgeSupport() async {
    try {
      final isSupported = await AppBadgePlus.isSupported();
      if (isSupported) {
        // Test with a badge count of 1
        await AppBadgePlus.updateBadge(1);
        print('BadgeService: Badge support test successful - badge should show "1"');
        // Wait a moment then clear
        await Future.delayed(const Duration(seconds: 2));
        await AppBadgePlus.updateBadge(0);
        return true;
      } else {
        print('BadgeService: Badge support test failed - badges not supported');
        return false;
      }
    } catch (e) {
      print('BadgeService: Badge support test error: $e');
      return false;
    }
  }
}

