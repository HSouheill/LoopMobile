import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceUuidService {
  static const String _deviceUuidKey = 'device_uuid';
  static String? _cachedDeviceUuid;

  /// Get the device UUID. If it doesn't exist, create and store a new one.
  /// This UUID will remain the same for the lifetime of the app installation.
  static Future<String> getDeviceUuid() async {
    if (_cachedDeviceUuid != null) {
      return _cachedDeviceUuid!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedUuid = prefs.getString(_deviceUuidKey);

      if (storedUuid == null || storedUuid.isEmpty) {
        // Generate a new UUID for this device
        const uuid = Uuid();
        storedUuid = uuid.v4();
        
        // Store it for future use
        await prefs.setString(_deviceUuidKey, storedUuid);
      }

      _cachedDeviceUuid = storedUuid;
      return storedUuid;
    } catch (e) {
      // Fallback: generate a new UUID if storage fails
      const uuid = Uuid();
      final fallbackUuid = uuid.v4();
      _cachedDeviceUuid = fallbackUuid;
      return fallbackUuid;
    }
  }

  /// Get the device UUID synchronously (returns cached value or null)
  static String? getCachedDeviceUuid() {
    return _cachedDeviceUuid;
  }

  /// Clear the stored device UUID (useful for testing or if user wants to reset)
  static Future<void> clearDeviceUuid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceUuidKey);
      _cachedDeviceUuid = null;
    } catch (e) {
      // Handle error silently
    }
  }

  /// Initialize the device UUID (call this when the app starts)
  static Future<void> initialize() async {
    await getDeviceUuid();
  }
}
