// File: lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LocationService {
  static const String _currentLocationKey = 'current_location';
  static const String _locationTimestampKey = 'location_timestamp';
  static const Duration _cacheValidDuration = Duration(hours: 1); // Cache location for 1 hour

  /// Get the current city name from device location
  /// Returns cached city if available and not expired
  /// Otherwise, fetches fresh location
  static Future<String?> getCurrentCity() async {
    try {
      // Check if we have a valid cached location
      final cachedCity = await _getCachedCity();
      if (cachedCity != null) {
        return cachedCity;
      }

      // Fetch fresh location
      return await _fetchCurrentCity();
    } catch (e) {
      return null;
    }
  }

  /// Force refresh location (used on app launch)
  static Future<String?> refreshCurrentCity() async {
    try {
      return await _fetchCurrentCity();
    } catch (e) {
      return null;
    }
  }

  /// Get cached city if available and not expired
  static Future<String?> _getCachedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedCity = prefs.getString(_currentLocationKey);
      final timestamp = prefs.getInt(_locationTimestampKey);

      if (cachedCity != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        
        if (now.difference(cacheTime) < _cacheValidDuration) {
          return cachedCity;
        }
      }
    } catch (e) {
      // Error reading cache
    }
    return null;
  }

  /// Fetch current city from device location
  static Future<String?> _fetchCurrentCity() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // Try to get the most appropriate city name
        // Priority: locality > subAdministrativeArea > administrativeArea
        String? cityName = placemark.locality ?? 
                          placemark.subAdministrativeArea ?? 
                          placemark.administrativeArea;

        if (cityName != null && cityName.isNotEmpty) {
          // Cache the result
          await _cacheCity(cityName);
          
          return cityName;
        }
      }

      return null;
    } on TimeoutException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache city name with timestamp
  static Future<void> _cacheCity(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentLocationKey, cityName);
      await prefs.setInt(_locationTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Error caching city
    }
  }

  /// Clear cached location
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentLocationKey);
      await prefs.remove(_locationTimestampKey);
    } catch (e) {
      // Error clearing cache
    }
  }

  /// Get last cached city without checking expiry
  static Future<String?> getLastKnownCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currentLocationKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }
}

