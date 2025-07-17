import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/gps_tracking_service.dart';

/// Location Permission Widget for HomeLinkGH
/// Handles location permission requests and settings navigation
class LocationPermissionWidget extends StatefulWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  final bool showAsDialog;
  final String? customMessage;

  const LocationPermissionWidget({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
    this.showAsDialog = false,
    this.customMessage,
  });

  @override
  State<LocationPermissionWidget> createState() => _LocationPermissionWidgetState();
}

class _LocationPermissionWidgetState extends State<LocationPermissionWidget> {
  final GPSTrackingService _gpsService = GPSTrackingService();
  bool _isCheckingPermissions = false;
  LocationPermission? _currentPermission;
  bool _locationServicesEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    setState(() => _isCheckingPermissions = true);

    try {
      _locationServicesEnabled = await _gpsService.areLocationServicesEnabled();
      _currentPermission = await _gpsService.getLocationPermissionStatus();
    } catch (e) {
      print('Error checking location status: $e');
    }

    setState(() => _isCheckingPermissions = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAsDialog) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _buildContent(),
      );
    } else {
      return _buildContent();
    }
  }

  Widget _buildContent() {
    if (_isCheckingPermissions) {
      return _buildLoadingState();
    }

    if (!_locationServicesEnabled) {
      return _buildLocationServicesDisabled();
    }

    switch (_currentPermission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return _buildPermissionGranted();
      case LocationPermission.denied:
        return _buildPermissionRequest();
      case LocationPermission.deniedForever:
        return _buildPermissionDeniedForever();
      default:
        return _buildPermissionRequest();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Checking location permissions...'),
        ],
      ),
    );
  }

  Widget _buildLocationServicesDisabled() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_disabled,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'Location Services Disabled',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.customMessage ?? 
            'HomeLinkGH needs location services to find nearby providers and track deliveries. Please enable location services in your device settings.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onPermissionDenied?.call();
                    if (widget.showAsDialog) Navigator.pop(context);
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _openLocationSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Open Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            size: 64,
            color: Color(0xFF006B3C),
          ),
          const SizedBox(height: 16),
          const Text(
            'Location Permission Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.customMessage ?? 
            'HomeLinkGH uses your location to:\n\n'
            '• Find nearby service providers\n'
            '• Calculate accurate delivery times\n'
            '• Track service progress\n'
            '• Provide location-based recommendations',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your location data is encrypted and used only for service delivery.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onPermissionDenied?.call();
                    if (widget.showAsDialog) Navigator.pop(context);
                  },
                  child: const Text('Not Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Allow Location'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionGranted() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'Location Access Granted!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'You can now enjoy location-based features including nearby provider discovery and real-time tracking.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onPermissionGranted?.call();
                if (widget.showAsDialog) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedForever() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_off,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Location Permission Denied',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Location access has been permanently denied. To enable location features, please grant permission in your app settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Text(
                  'How to enable location:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Open device Settings\n'
                  '2. Find HomeLinkGH app\n'
                  '3. Enable Location permissions',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onPermissionDenied?.call();
                    if (widget.showAsDialog) Navigator.pop(context);
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _openAppSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('App Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission() async {
    setState(() => _isCheckingPermissions = true);

    try {
      bool granted = await _gpsService.requestLocationPermissions();
      
      if (granted) {
        widget.onPermissionGranted?.call();
        if (widget.showAsDialog && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        await _checkLocationStatus(); // Refresh status
      }
    } catch (e) {
      print('Error requesting permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting permission: $e')),
        );
      }
    }

    setState(() => _isCheckingPermissions = false);
  }

  Future<void> _openLocationSettings() async {
    try {
      bool opened = await _gpsService.openLocationSettings();
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open location settings')),
        );
      }
    } catch (e) {
      print('Error opening location settings: $e');
    }
  }

  Future<void> _openAppSettings() async {
    try {
      bool opened = await _gpsService.openAppSettings();
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open app settings')),
        );
      }
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }
}

/// Helper function to show location permission dialog
Future<bool?> showLocationPermissionDialog(
  BuildContext context, {
  String? customMessage,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => LocationPermissionWidget(
      showAsDialog: true,
      customMessage: customMessage,
      onPermissionGranted: () => Navigator.pop(context, true),
      onPermissionDenied: () => Navigator.pop(context, false),
    ),
  );
}

/// Location permission status widget for settings screens
class LocationPermissionStatusWidget extends StatefulWidget {
  const LocationPermissionStatusWidget({super.key});

  @override
  State<LocationPermissionStatusWidget> createState() => _LocationPermissionStatusWidgetState();
}

class _LocationPermissionStatusWidgetState extends State<LocationPermissionStatusWidget> {
  final GPSTrackingService _gpsService = GPSTrackingService();
  LocationPermission? _permission;
  bool _servicesEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    
    try {
      _permission = await _gpsService.getLocationPermissionStatus();
      _servicesEnabled = await _gpsService.areLocationServicesEnabled();
    } catch (e) {
      print('Error checking location status: $e');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Checking location status...'),
      );
    }

    IconData icon;
    Color iconColor;
    String status;
    String subtitle;

    if (!_servicesEnabled) {
      icon = Icons.location_disabled;
      iconColor = Colors.red;
      status = 'Location Services Disabled';
      subtitle = 'Enable location services in device settings';
    } else {
      switch (_permission) {
        case LocationPermission.always:
          icon = Icons.location_on;
          iconColor = Colors.green;
          status = 'Always Allowed';
          subtitle = 'Location access granted for all features';
          break;
        case LocationPermission.whileInUse:
          icon = Icons.location_on;
          iconColor = Colors.green;
          status = 'While Using App';
          subtitle = 'Location access granted while app is open';
          break;
        case LocationPermission.denied:
          icon = Icons.location_off;
          iconColor = Colors.orange;
          status = 'Permission Denied';
          subtitle = 'Tap to request location permission';
          break;
        case LocationPermission.deniedForever:
          icon = Icons.location_off;
          iconColor = Colors.red;
          status = 'Permanently Denied';
          subtitle = 'Enable in app settings to use location features';
          break;
        default:
          icon = Icons.location_searching;
          iconColor = Colors.grey;
          status = 'Unknown';
          subtitle = 'Unable to determine location permission status';
      }
    }

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 32),
      title: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: iconColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () async {
        await showLocationPermissionDialog(context);
        _checkStatus(); // Refresh status after dialog
      },
    );
  }
}