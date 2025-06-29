import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/gps_tracking_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

/// Real-time booking tracking screen with live provider location and status updates
class BookingTrackingScreen extends StatefulWidget {
  final String bookingId;
  final String currentUserId;
  final String currentUserType;

  const BookingTrackingScreen({
    super.key,
    required this.bookingId,
    required this.currentUserId,
    required this.currentUserType,
  });

  @override
  State<BookingTrackingScreen> createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen> {
  final BookingService _bookingService = BookingService();
  final GpsTrackingService _trackingService = GpsTrackingService();
  final ChatService _chatService = ChatService();
  
  GoogleMapController? _mapController;
  Booking? _currentBooking;
  Map<String, dynamic>? _bookingDetails;
  LatLng? _providerLocation;
  LatLng? _serviceLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
    _startLocationTracking();
    _loadUnreadMessageCount();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _loadBookingDetails() async {
    final details = await _bookingService.getBookingWithDetails(widget.bookingId);
    if (details != null && mounted) {
      setState(() {
        _currentBooking = details['booking'];
        _bookingDetails = details;
      });
      
      // Set service location from booking data
      final bookingData = details['bookingData'] as Map<String, dynamic>;
      final locationData = bookingData['location'] as Map<String, dynamic>?;
      if (locationData != null) {
        _serviceLocation = LatLng(
          locationData['latitude'] as double,
          locationData['longitude'] as double,
        );
        _updateMarkers();
      }
    }
  }

  void _startLocationTracking() {
    if (_currentBooking?.status == 'in_progress') {
      _trackingService.getLocationStream(widget.bookingId).listen((location) {
        if (mounted && location != null) {
          setState(() {
            _providerLocation = LatLng(location.latitude, location.longitude);
          });
          _updateMarkers();
          _updatePolylines();
        }
      });
    }
  }

  void _loadUnreadMessageCount() async {
    final count = await _chatService.getUnreadMessageCount(widget.bookingId, widget.currentUserId);
    if (mounted) {
      setState(() {
        _unreadMessageCount = count;
      });
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};
    
    // Service location marker
    if (_serviceLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('service_location'),
          position: _serviceLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Service Location',
            snippet: _currentBooking?.address ?? 'Service address',
          ),
        ),
      );
    }
    
    // Provider location marker (if service is in progress)
    if (_providerLocation != null && _currentBooking?.status == 'in_progress') {
      markers.add(
        Marker(
          markerId: const MarkerId('provider_location'),
          position: _providerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Provider Location',
            snippet: _bookingDetails?['provider']?['name'] ?? 'Service Provider',
          ),
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }

  void _updatePolylines() {
    if (_serviceLocation != null && _providerLocation != null) {
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: [_providerLocation!, _serviceLocation!],
        color: const Color(0xFF006B3C),
        width: 3,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );
      
      setState(() {
        _polylines = {polyline};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _currentBooking == null 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatusTimeline(),
                Expanded(child: _buildMap()),
                _buildBottomPanel(),
              ],
            ),
      floatingActionButton: _buildChatFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF006B3C),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Track Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (_currentBooking != null)
            Text(
              _currentBooking!.serviceType,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStatusTimeline() {
    if (_currentBooking == null) return const SizedBox.shrink();

    final statuses = [
      {'key': 'pending', 'label': 'Pending', 'icon': Icons.schedule},
      {'key': 'accepted', 'label': 'Accepted', 'icon': Icons.check_circle},
      {'key': 'confirmed', 'label': 'Confirmed', 'icon': Icons.verified},
      {'key': 'in_progress', 'label': 'In Progress', 'icon': Icons.play_circle},
      {'key': 'completed', 'label': 'Completed', 'icon': Icons.done_all},
    ];

    final currentStatusIndex = statuses.indexWhere((s) => s['key'] == _currentBooking!.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                final isCompleted = index <= currentStatusIndex;
                final isCurrent = index == currentStatusIndex;
                
                return Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCompleted 
                                ? const Color(0xFF006B3C)
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: isCurrent 
                                ? Border.all(color: const Color(0xFF006B3C), width: 3)
                                : null,
                          ),
                          child: Icon(
                            status['icon'] as IconData,
                            color: isCompleted ? Colors.white : Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCompleted 
                                ? const Color(0xFF006B3C)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (index < statuses.length - 1)
                      Container(
                        width: 30,
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 20),
                        color: index < currentStatusIndex 
                            ? const Color(0xFF006B3C)
                            : Colors.grey.shade300,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_serviceLocation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading map...'),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _serviceLocation!,
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        _mapController = controller;
        _fitMarkersOnMap();
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: false,
    );
  }

  Widget _buildBottomPanel() {
    if (_currentBooking == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentBooking!.serviceType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GH₵${_currentBooking!.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 12),
          _buildProviderInfo(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    if (_currentBooking == null) return const SizedBox.shrink();

    Color chipColor;
    String statusText;

    switch (_currentBooking!.status) {
      case 'pending':
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'accepted':
        chipColor = Colors.blue;
        statusText = 'Accepted';
        break;
      case 'confirmed':
        chipColor = Colors.green;
        statusText = 'Confirmed';
        break;
      case 'in_progress':
        chipColor = const Color(0xFF006B3C);
        statusText = 'In Progress';
        break;
      case 'completed':
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'cancelled':
        chipColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        chipColor = Colors.grey;
        statusText = _currentBooking!.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProviderInfo() {
    final provider = _bookingDetails?['provider'] as Map<String, dynamic>?;
    if (provider == null) return const SizedBox.shrink();

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF006B3C),
          child: Text(
            provider['name']?.toString().isNotEmpty == true
                ? provider['name'][0].toUpperCase()
                : 'P',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider['name'] ?? 'Service Provider',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Rating: ${provider['rating']?.toStringAsFixed(1) ?? 'N/A'} ⭐',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        if (_currentBooking!.status == 'in_progress' && _providerLocation != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'ETA',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '~15 min',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF006B3C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.phone),
            label: const Text('Call Provider'),
            onPressed: _callProvider,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF006B3C),
              side: const BorderSide(color: Color(0xFF006B3C)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat),
            label: const Text('Chat'),
            onPressed: _openChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatFAB() {
    return FloatingActionButton(
      onPressed: _openChat,
      backgroundColor: const Color(0xFF006B3C),
      child: Stack(
        children: [
          const Icon(Icons.chat, color: Colors.white),
          if (_unreadMessageCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  _unreadMessageCount > 9 ? '9+' : _unreadMessageCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _fitMarkersOnMap() {
    if (_mapController == null || _markers.isEmpty) return;

    final bounds = _calculateBounds();
    if (bounds != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  LatLngBounds? _calculateBounds() {
    if (_markers.isEmpty) return null;

    final latitudes = _markers.map((m) => m.position.latitude).toList();
    final longitudes = _markers.map((m) => m.position.longitude).toList();

    latitudes.sort();
    longitudes.sort();

    return LatLngBounds(
      southwest: LatLng(latitudes.first, longitudes.first),
      northeast: LatLng(latitudes.last, longitudes.last),
    );
  }

  void _refreshData() {
    _loadBookingDetails();
    _loadUnreadMessageCount();
    
    if (_currentBooking?.status == 'in_progress') {
      _startLocationTracking();
    }
  }

  void _callProvider() {
    // TODO: Implement provider call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Call functionality coming soon!')),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          bookingId: widget.bookingId,
          currentUserId: widget.currentUserId,
          currentUserType: widget.currentUserType,
          currentUserName: 'Current User', // TODO: Get actual user name
        ),
      ),
    ).then((_) {
      // Refresh unread count when returning from chat
      _loadUnreadMessageCount();
    });
  }
}