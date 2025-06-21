import 'package:flutter/material.dart';
import 'dart:async';

class FoodDeliveryTrackingScreen extends StatefulWidget {
  final String orderId;
  final String restaurantName;
  final String driverName;
  
  const FoodDeliveryTrackingScreen({
    super.key,
    required this.orderId,
    required this.restaurantName,
    required this.driverName,
  });

  @override
  State<FoodDeliveryTrackingScreen> createState() => _FoodDeliveryTrackingScreenState();
}

class _FoodDeliveryTrackingScreenState extends State<FoodDeliveryTrackingScreen> {
  int currentStep = 1;
  Timer? _timer;
  String estimatedTime = '25-35 min';
  String driverLocation = 'On the way to restaurant';
  
  final List<Map<String, dynamic>> orderSteps = [
    {
      'title': 'Order Confirmed',
      'subtitle': 'Restaurant is preparing your food',
      'icon': Icons.restaurant_menu,
      'time': '2:30 PM',
      'completed': true,
    },
    {
      'title': 'Preparing Food',
      'subtitle': 'Your order is being prepared',
      'icon': Icons.kitchen,
      'time': '2:35 PM',
      'completed': true,
    },
    {
      'title': 'Driver Assigned',
      'subtitle': 'Your driver is on the way',
      'icon': Icons.person,
      'time': '2:40 PM',
      'completed': false,
    },
    {
      'title': 'Food Ready',
      'subtitle': 'Driver is picking up your order',
      'icon': Icons.shopping_bag,
      'time': '',
      'completed': false,
    },
    {
      'title': 'On the Way',
      'subtitle': 'Driver is heading to your location',
      'icon': Icons.delivery_dining,
      'time': '',
      'completed': false,
    },
    {
      'title': 'Delivered',
      'subtitle': 'Enjoy your meal!',
      'icon': Icons.check_circle,
      'time': '',
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (currentStep < orderSteps.length - 1) {
        setState(() {
          orderSteps[currentStep]['completed'] = true;
          currentStep++;
          _updateEstimatedTime();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _updateEstimatedTime() {
    switch (currentStep) {
      case 2:
        estimatedTime = '20-30 min';
        driverLocation = 'Heading to restaurant';
        break;
      case 3:
        estimatedTime = '15-25 min';
        driverLocation = 'At restaurant';
        break;
      case 4:
        estimatedTime = '10-15 min';
        driverLocation = 'On the way to you';
        break;
      case 5:
        estimatedTime = '2-5 min';
        driverLocation = 'Nearby';
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Your Order'),
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        foregroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () => _showSupportOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.red),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.restaurantName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Order #${widget.orderId}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          estimatedTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Estimated',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 16,
                        child: Icon(Icons.person, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.driverName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              driverLocation,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _callDriver(),
                        icon: const Icon(Icons.phone, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () => _messageDriver(),
                        icon: const Icon(Icons.message, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderSteps.length,
              itemBuilder: (context, index) {
                final step = orderSteps[index];
                final isCompleted = step['completed'];
                final isCurrent = index == currentStep && !isCompleted;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green : 
                                     isCurrent ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : step['icon'],
                              color: isCompleted || isCurrent ? Colors.white : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                          if (index < orderSteps.length - 1)
                            Container(
                              width: 2,
                              height: 40,
                              color: isCompleted ? Colors.green : Colors.grey[300],
                            ),
                        ],
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
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.green : 
                                       isCurrent ? Colors.blue : Colors.grey[600],
                              ),
                            ),
                            Text(
                              step['subtitle'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            if (step['time'].isNotEmpty)
                              Text(
                                step['time'],
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (currentStep < orderSteps.length - 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _modifyOrder(),
                      child: const Text('Modify Order'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _cancelOrder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel Order'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _callDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${widget.driverName}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _messageDriver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message ${widget.driverName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message sent to driver'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _modifyOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Order'),
        content: const Text('Order modifications are limited after preparation begins. Contact support for assistance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSupportOptions();
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? You may be charged a cancellation fee.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCancellation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processCancellation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully. Refund will be processed in 3-5 business days.'),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  void _showSupportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat'),
              subtitle: const Text('Get instant help'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening live chat...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Support'),
              subtitle: const Text('0800-123-4567'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling support...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@blazer.com'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}