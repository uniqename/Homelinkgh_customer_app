import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/provider.dart';

class TrackingScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final Provider provider;
  final double estimatedDeliveryTime;
  final LatLng customerLocation;
  final String deliveryAddress;

  const TrackingScreen({
    super.key,
    required this.restaurant,
    required this.provider,
    required this.estimatedDeliveryTime,
    required this.customerLocation,
    required this.deliveryAddress,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _timer;
  int _currentStep = 0;
  double _remainingTime = 0;
  LatLng _providerCurrentLocation = const LatLng(0, 0);
  
  final List<Map<String, dynamic>> _deliverySteps = [
    {
      'title': 'Order Confirmed',
      'subtitle': 'Restaurant is preparing your order',
      'icon': Icons.restaurant,
      'color': Colors.green,
    },
    {
      'title': 'Food Ready',
      'subtitle': 'Your order is ready for pickup',
      'icon': Icons.check_circle,
      'color': Colors.blue,
    },
    {
      'title': 'On the way',
      'subtitle': 'Delivery partner is heading to you',
      'icon': Icons.delivery_dining,
      'color': Colors.orange,
    },
    {
      'title': 'Delivered',
      'subtitle': 'Enjoy your meal!',
      'icon': Icons.home,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.estimatedDeliveryTime;
    _providerCurrentLocation = widget.provider.location;
    _startTracking();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        // Simulate progress
        if (_remainingTime > 0) {
          _remainingTime -= 0.5; // Decrease by 30 seconds
          
          // Update steps based on time
          if (_remainingTime <= widget.estimatedDeliveryTime * 0.25) {
            _currentStep = 3; // Delivered
          } else if (_remainingTime <= widget.estimatedDeliveryTime * 0.5) {
            _currentStep = 2; // On the way
          } else if (_remainingTime <= widget.estimatedDeliveryTime * 0.75) {
            _currentStep = 1; // Food ready
          } else {
            _currentStep = 0; // Order confirmed
          }
          
          // Simulate provider movement
          _simulateProviderMovement();
        } else {
          _currentStep = 3; // Completed
          timer.cancel();
        }
      });
    });
  }

  void _simulateProviderMovement() {
    // Simulate provider moving towards customer
    final double progress = 1 - (_remainingTime / widget.estimatedDeliveryTime);
    final double newLat = widget.provider.location.latitude + 
        (widget.customerLocation.latitude - widget.provider.location.latitude) * progress;
    final double newLng = widget.provider.location.longitude + 
        (widget.customerLocation.longitude - widget.provider.location.longitude) * progress;
    
    _providerCurrentLocation = LatLng(newLat, newLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Your Order'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _callProvider,
          ),
        ],
      ),
      body: Column(
        children: [
          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      widget.restaurant['image'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Order #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_remainingTime.round()} min',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                    const Text('remaining'),
                  ],
                ),
              ],
            ),
          ),
          
          // Map Section (Simulated)
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map,
                        size: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Live Tracking Map',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Provider: ${_providerCurrentLocation.latitude.toStringAsFixed(4)}, ${_providerCurrentLocation.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentStep >= 2) // Show moving icon when on the way
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF006B3C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Provider Info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF006B3C),
                  child: Text(
                    widget.provider.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.provider.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.provider.rating}'),
                          const SizedBox(width: 16),
                          Text('${widget.provider.completedJobs} deliveries'),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _callProvider,
                  icon: const Icon(Icons.phone, color: Color(0xFF006B3C)),
                ),
                IconButton(
                  onPressed: _messageProvider,
                  icon: const Icon(Icons.message, color: Color(0xFF006B3C)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Delivery Progress
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _deliverySteps.length,
                      itemBuilder: (context, index) {
                        final step = _deliverySteps[index];
                        final isCompleted = index <= _currentStep;
                        final isActive = index == _currentStep;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCompleted 
                                      ? step['color']
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  step['icon'],
                                  color: isCompleted ? Colors.white : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isActive 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        color: isCompleted 
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      step['subtitle'],
                                      style: TextStyle(
                                        color: isCompleted 
                                            ? Colors.grey[600]
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: step['color'],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callProvider() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call ${widget.provider.name}?'),
        content: const Text('This would initiate a phone call to your delivery partner.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling delivery partner...')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _messageProvider() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message ${widget.provider.name}'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Type your message...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message sent!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

