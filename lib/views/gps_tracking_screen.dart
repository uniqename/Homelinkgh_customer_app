import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/gps_tracking_service.dart';
import '../widgets/location_permission_widget.dart';

/// GPS Tracking Screen for HomeLinkGH
/// Displays real-time location tracking and service delivery status
class GPSTrackingScreen extends StatefulWidget {
  final String? trackingId;
  final String? bookingId;
  final bool isProvider;

  const GPSTrackingScreen({
    super.key,
    this.trackingId,
    this.bookingId,
    this.isProvider = false,
  });

  @override
  State<GPSTrackingScreen> createState() => _GPSTrackingScreenState();
}

class _GPSTrackingScreenState extends State<GPSTrackingScreen> {
  final GPSTrackingService _gpsService = GPSTrackingService();
  
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<String>? _addressSubscription;
  StreamSubscription<Map<String, dynamic>>? _locationUpdateSubscription;
  
  Position? _currentPosition;
  String? _currentAddress;
  bool _isTracking = false;
  bool _hasLocationPermission = false;
  List<Map<String, dynamic>> _locationHistory = [];
  List<Map<String, dynamic>> _nearbyProviders = [];
  Map<String, dynamic>? _locationInsights;
  
  String? _trackingId;
  bool _isLoadingNearbyProviders = false;

  @override
  void initState() {
    super.initState();
    _trackingId = widget.trackingId;
    _initializeTracking();
  }

  @override
  void dispose() {
    _stopTrackingSubscriptions();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    // Check permissions first
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      setState(() => _hasLocationPermission = false);
      return;
    }

    setState(() => _hasLocationPermission = true);

    // Initialize GPS service
    final initialized = await _gpsService.initialize();
    if (!initialized) {
      _showError('Failed to initialize GPS tracking');
      return;
    }

    // Get current position
    final position = await _gpsService.getCurrentPosition();
    if (position != null) {
      setState(() => _currentPosition = position);
    }

    // Start tracking if this is a service delivery
    if (widget.trackingId != null || widget.isProvider) {
      await _startServiceTracking();
    }

    // Set up location streams
    _setupLocationStreams();

    // Load location insights
    _loadLocationInsights();

    // Load location history
    _loadLocationHistory();
  }

  Future<bool> _checkLocationPermission() async {
    final permission = await _gpsService.getLocationPermissionStatus();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  void _setupLocationStreams() {
    // Position updates
    _positionSubscription = _gpsService.positionStream.listen(
      (position) {
        setState(() => _currentPosition = position);
      },
      onError: (error) {
        print('Position stream error: $error');
        _showError('Location tracking error: $error');
      },
    );

    // Address updates
    _addressSubscription = _gpsService.addressStream.listen(
      (address) {
        setState(() => _currentAddress = address);
      },
    );

    // Location updates
    _locationUpdateSubscription = _gpsService.locationUpdateStream.listen(
      (update) {
        _handleLocationUpdate(update);
      },
    );
  }

  void _handleLocationUpdate(Map<String, dynamic> update) {
    print('Location update: ${update['type']}');
    
    if (update['type'] == 'tracking_stopped') {
      setState(() => _isTracking = false);
    } else if (update['type'] == 'position_update') {
      // Update any UI components that need real-time updates
      if (mounted) {
        setState(() {});
      }
    } else if (update['type'] == 'error') {
      _showError(update['message']);
    }
  }

  Future<void> _startServiceTracking() async {
    try {
      if (_trackingId == null && widget.bookingId != null) {
        // Start new tracking for service delivery
        _trackingId = await _gpsService.startServiceDeliveryTracking(
          bookingId: widget.bookingId!,
          providerId: widget.isProvider ? 'current_provider' : 'provider_id',
          customerId: widget.isProvider ? 'customer_id' : 'current_customer',
        );
      }

      final success = await _gpsService.startTracking(
        updateIntervalSeconds: widget.isProvider ? 5 : 10,
        distanceFilterMeters: widget.isProvider ? 5.0 : 10.0,
      );

      setState(() => _isTracking = success);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isProvider 
              ? 'Service delivery tracking started' 
              : 'Location tracking started'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error starting service tracking: $e');
      _showError('Failed to start tracking: $e');
    }
  }

  Future<void> _stopServiceTracking() async {
    try {
      if (_trackingId != null) {
        await _gpsService.stopServiceDeliveryTracking(_trackingId!);
      }
      
      await _gpsService.stopTracking();
      setState(() => _isTracking = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tracking stopped'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print('Error stopping tracking: $e');
      _showError('Failed to stop tracking: $e');
    }
  }

  void _stopTrackingSubscriptions() {
    _positionSubscription?.cancel();
    _addressSubscription?.cancel();
    _locationUpdateSubscription?.cancel();
  }

  Future<void> _loadLocationInsights() async {
    final insights = _gpsService.getGhanaLocationInsights();
    setState(() => _locationInsights = insights);
  }

  Future<void> _loadLocationHistory() async {
    try {
      final history = await _gpsService.getLocationHistory(limitDays: 1);
      setState(() => _locationHistory = history);
    } catch (e) {
      print('Error loading location history: $e');
    }
  }

  Future<void> _findNearbyProviders() async {
    setState(() => _isLoadingNearbyProviders = true);

    try {
      final providers = await _gpsService.findNearbyProviders(
        serviceType: 'Food Delivery', // Default service type
        radiusKm: 10.0,
        limit: 10,
      );
      setState(() => _nearbyProviders = providers);
    } catch (e) {
      print('Error finding nearby providers: $e');
      _showError('Failed to find nearby providers: $e');
    }

    setState(() => _isLoadingNearbyProviders = false);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isProvider ? 'Service Tracking' : 'Location Tracking'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          if (_hasLocationPermission)
            IconButton(
              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
              onPressed: _isTracking ? _stopServiceTracking : _startServiceTracking,
              tooltip: _isTracking ? 'Stop Tracking' : 'Start Tracking',
            ),
        ],
      ),
      body: _hasLocationPermission ? _buildTrackingContent() : _buildPermissionRequest(),
    );
  }

  Widget _buildPermissionRequest() {
    return const LocationPermissionWidget(
      customMessage: 'GPS tracking requires location access to provide real-time updates and find nearby services.',
    );
  }

  Widget _buildTrackingContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadLocationInsights();
        await _loadLocationHistory();
        if (_nearbyProviders.isNotEmpty || _isLoadingNearbyProviders) {
          await _findNearbyProviders();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrackingStatus(),
            const SizedBox(height: 20),
            _buildCurrentLocation(),
            const SizedBox(height: 20),
            if (_locationInsights != null) ...[
              _buildLocationInsights(),
              const SizedBox(height: 20),
            ],
            if (widget.isProvider) ...[
              _buildServiceDeliveryControls(),
              const SizedBox(height: 20),
            ],
            _buildNearbyProvidersSection(),
            const SizedBox(height: 20),
            _buildLocationHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStatus() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isTracking ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: _isTracking ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isTracking ? 'Tracking Active' : 'Tracking Inactive',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isTracking ? Colors.green : Colors.grey,
                        ),
                      ),
                      Text(
                        _isTracking 
                          ? 'Your location is being tracked for service delivery'
                          : 'Start tracking to enable location-based features',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_trackingId != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tracking ID: ${_trackingId!.substring(0, 12)}...',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.my_location, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text(
                  'Current Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentPosition != null) ...[
              _buildLocationInfoRow('Coordinates', 
                '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'),
              _buildLocationInfoRow('Accuracy', '±${_currentPosition!.accuracy.toStringAsFixed(1)}m'),
              if (_currentPosition!.altitude != null)
                _buildLocationInfoRow('Altitude', '${_currentPosition!.altitude!.toStringAsFixed(1)}m'),
              if (_currentPosition!.speed != null)
                _buildLocationInfoRow('Speed', '${(_currentPosition!.speed! * 3.6).toStringAsFixed(1)} km/h'),
              if (_currentAddress != null)
                _buildLocationInfoRow('Address', _currentAddress!),
              _buildLocationInfoRow('Last Update', 
                _currentPosition!.timestamp?.toString().split('.')[0] ?? 'Unknown'),
            ] else ...[
              const Text('Getting location...', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInsights() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.insights, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text(
                  'Location Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLocationInfoRow('Region', _locationInsights!['region'] ?? 'Unknown'),
            _buildLocationInfoRow('Classification', _locationInsights!['urban_classification'] ?? 'Unknown'),
            _buildLocationInfoRow('Service Availability', _locationInsights!['service_availability'] ?? 'Unknown'),
            _buildLocationInfoRow('Peak Hours', (_locationInsights!['peak_hours'] as List?)?.join(', ') ?? 'Unknown'),
            _buildLocationInfoRow('Weather Suitability', _locationInsights!['weather_suitability'] ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDeliveryControls() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.delivery_dining, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text(
                  'Service Delivery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Provider controls for managing service delivery tracking.'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTracking ? null : _startServiceTracking,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Delivery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTracking ? _stopServiceTracking : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Complete Delivery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyProvidersSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.near_me, color: Color(0xFF006B3C)),
                    SizedBox(width: 8),
                    Text(
                      'Nearby Providers',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _isLoadingNearbyProviders ? null : _findNearbyProviders,
                  child: _isLoadingNearbyProviders 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Find'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_nearbyProviders.isEmpty && !_isLoadingNearbyProviders)
              const Text('Tap "Find" to discover nearby service providers.')
            else if (_nearbyProviders.isNotEmpty)
              Column(
                children: _nearbyProviders.take(3).map((provider) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF006B3C),
                      child: Text(
                        provider['name']?[0] ?? 'P',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(provider['name'] ?? 'Unknown Provider'),
                    subtitle: Text(
                      '${provider['distance_km']?.toStringAsFixed(1) ?? '?'} km away • '
                      '${provider['estimated_travel_time'] ?? '? min'}',
                    ),
                    trailing: Text(
                      '⭐ ${provider['rating']?.toStringAsFixed(1) ?? '0.0'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHistory() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF006B3C)),
                SizedBox(width: 8),
                Text(
                  'Recent Locations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_locationHistory.isEmpty)
              const Text('No recent location history available.')
            else
              Column(
                children: _locationHistory.take(5).map((location) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on, color: Colors.grey),
                    title: Text(location['address'] ?? 'Unknown location'),
                    subtitle: Text(
                      'Accuracy: ±${location['accuracy']?.toStringAsFixed(1) ?? '?'}m',
                    ),
                    trailing: Text(
                      DateTime.tryParse(location['timestamp'] ?? '')
                        ?.toString().split(' ')[1].substring(0, 5) ?? 'Unknown',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}