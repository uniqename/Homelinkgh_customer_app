import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Tracking Transparency Service for HomeLinkGH
/// Handles iOS 14.5+ tracking permission requirements
class AppTrackingService {
  static const String _trackingPreferenceKey = 'tracking_authorized';
  static const String _trackingRequestedKey = 'tracking_requested';

  /// Request tracking permission from user (iOS only)
  static Future<bool> requestTrackingPermission() async {
    if (!Platform.isIOS) {
      // Android doesn't require explicit tracking permission
      return true;
    }

    try {
      // Check current status first
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      
      if (status == TrackingStatus.authorized) {
        await _saveTrackingPreference(true);
        return true;
      }
      
      if (status == TrackingStatus.denied || status == TrackingStatus.restricted) {
        await _saveTrackingPreference(false);
        return false;
      }

      // Request permission if not determined
      if (status == TrackingStatus.notDetermined) {
        final TrackingStatus newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
        
        final authorized = newStatus == TrackingStatus.authorized;
        await _saveTrackingPreference(authorized);
        await _markTrackingRequested();
        
        return authorized;
      }

      return false;
    } catch (e) {
      print('Error requesting tracking permission: $e');
      await _saveTrackingPreference(false);
      return false;
    }
  }

  /// Check if tracking is currently authorized
  static Future<bool> isTrackingAuthorized() async {
    if (!Platform.isIOS) {
      return true; // Android doesn't require explicit permission
    }

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      final authorized = status == TrackingStatus.authorized;
      await _saveTrackingPreference(authorized);
      return authorized;
    } catch (e) {
      print('Error checking tracking authorization: $e');
      return false;
    }
  }

  /// Check if we've already requested tracking permission
  static Future<bool> hasRequestedTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trackingRequestedKey) ?? false;
  }

  /// Get the tracking authorization status
  static Future<TrackingStatus> getTrackingStatus() async {
    if (!Platform.isIOS) {
      return TrackingStatus.authorized;
    }

    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      print('Error getting tracking status: $e');
      return TrackingStatus.denied;
    }
  }

  /// Show tracking permission dialog with context
  static Future<bool> showTrackingDialog(BuildContext context) async {
    if (!Platform.isIOS) {
      return true;
    }

    // Check if already requested
    final hasRequested = await hasRequestedTracking();
    final isAuthorized = await isTrackingAuthorized();

    if (hasRequested && !isAuthorized) {
      // Already denied, don't show again
      return false;
    }

    if (isAuthorized) {
      return true;
    }

    // Show explanatory dialog first
    final shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.green),
              SizedBox(width: 8),
              Text('Privacy & Personalization'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To provide you with the best experience, HomeLinkGH would like to:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Show nearby service providers'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Personalize service recommendations'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Improve app security and performance'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Your privacy is important to us. You can change this setting anytime in your device Settings.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );

    if (shouldRequest == true) {
      return await requestTrackingPermission();
    }

    await _markTrackingRequested();
    return false;
  }

  /// Initialize tracking service on app start
  static Future<void> initializeTracking(BuildContext context) async {
    if (!Platform.isIOS) {
      return;
    }

    try {
      // Wait a bit for the app to fully load
      await Future.delayed(const Duration(seconds: 2));

      final status = await getTrackingStatus();
      
      if (status == TrackingStatus.notDetermined) {
        // Only show dialog if not determined
        await showTrackingDialog(context);
      } else if (status == TrackingStatus.authorized) {
        await _saveTrackingPreference(true);
      } else {
        await _saveTrackingPreference(false);
      }
    } catch (e) {
      print('Error initializing tracking: $e');
    }
  }

  /// Save tracking preference to local storage
  static Future<void> _saveTrackingPreference(bool authorized) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trackingPreferenceKey, authorized);
  }

  /// Mark that we've requested tracking permission
  static Future<void> _markTrackingRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trackingRequestedKey, true);
  }

  /// Get saved tracking preference
  static Future<bool> getSavedTrackingPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trackingPreferenceKey) ?? false;
  }

  /// Reset tracking preferences (for testing)
  static Future<void> resetTrackingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_trackingPreferenceKey);
    await prefs.remove(_trackingRequestedKey);
  }
}