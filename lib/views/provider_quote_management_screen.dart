import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class ProviderQuoteManagementScreen extends StatefulWidget {
  const ProviderQuoteManagementScreen({super.key});

  @override
  State<ProviderQuoteManagementScreen> createState() => _ProviderQuoteManagementScreenState();
}

class _ProviderQuoteManagementScreenState extends State<ProviderQuoteManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _pendingQuotes = [
    {
      'id': 'Q001',
      'customer': 'Akosua Mensah',
      'service': 'Plumbing',
      'description': 'Kitchen sink repair needed',
      'location': 'East Legon, Accra',
      'urgency': 'Urgent (same day)',
      'budget': '₵100-200',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'photos': 2,
      'status': 'pending',
      'details': {
        'specificIssue': 'Leak (pipes/faucets)',
        'issueLocation': 'Kitchen',
        'issueDuration': 'Few days',
        'waterLeaking': 'Yes, actively leaking',
      },
    },
    {
      'id': 'Q002',
      'customer': 'Kwame Boateng',
      'service': 'House Cleaning',
      'description': 'Deep cleaning for 3-bedroom house',
      'location': 'Airport Residential, Accra',
      'urgency': 'Scheduled (within 3 days)',
      'budget': '₵200-500',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'photos': 4,
      'status': 'pending',
      'details': {
        'houseType': '3 bedroom',
        'cleaningType': 'Deep cleaning',
        'roomsToClean': ['Living room', 'Bedrooms', 'Kitchen', 'Bathrooms'],
      },
    },
    {
      'id': 'Q003',
      'customer': 'Ama Dufie',
      'service': 'Electrical Services',
      'description': 'Generator connection needed',
      'location': 'Tema, Greater Accra',
      'urgency': 'When convenient',
      'budget': '₵500+',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'photos': 1,
      'status': 'pending',
      'details': {
        'workNeeded': 'Generator connection',
        'powerSource': 'ECG + Generator backup',
        'safetyUrgency': 'No - planned upgrade/install',
      },
    },
  ];

  final List<Map<String, dynamic>> _activeQuotes = [
    {
      'id': 'Q004',
      'customer': 'Joseph Ankrah',
      'service': 'Masonry',
      'description': 'Compound wall construction',
      'location': 'Kasoa, Central Region',
      'myQuote': 350,
      'quotedAt': DateTime.now().subtract(const Duration(hours: 8)),
      'status': 'quoted',
      'estimatedDuration': '2 days',
      'validUntil': DateTime.now().add(const Duration(days: 3)),
    },
    {
      'id': 'Q005',
      'customer': 'Grace Osei',
      'service': 'Carpentry',
      'description': 'Kitchen cabinet installation',
      'location': 'Kumasi, Ashanti Region',
      'myQuote': 280,
      'quotedAt': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'quoted',
      'estimatedDuration': '1 day',
      'validUntil': DateTime.now().add(const Duration(days: 2)),
    },
  ];

  final List<Map<String, dynamic>> _completedQuotes = [
    {
      'id': 'Q006',
      'customer': 'Daniel Mensah',
      'service': 'Roofing',
      'description': 'Leak repair for aluminum sheets',
      'location': 'Madina, Greater Accra',
      'myQuote': 120,
      'finalPrice': 150,
      'status': 'accepted',
      'completedAt': DateTime.now().subtract(const Duration(days: 2)),
      'customerRating': 4.5,
      'earnings': 127.50, // After commission
    },
    {
      'id': 'Q007',
      'customer': 'Esther Addo',
      'service': 'Beauty Services',
      'description': 'Bridal makeup for traditional ceremony',
      'location': 'Takoradi, Western Region',
      'myQuote': 200,
      'finalPrice': 200,
      'status': 'completed',
      'completedAt': DateTime.now().subtract(const Duration(days: 5)),
      'customerRating': 5.0,
      'earnings': 170.00, // After commission
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize push notifications
    NotificationService().initializePushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote Management'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Pending (${_pendingQuotes.length})',
              icon: const Icon(Icons.schedule),
            ),
            Tab(
              text: 'Active (${_activeQuotes.length})',
              icon: const Icon(Icons.assignment),
            ),
            Tab(
              text: 'Completed (${_completedQuotes.length})',
              icon: const Icon(Icons.check_circle),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingQuotesTab(),
          _buildActiveQuotesTab(),
          _buildCompletedQuotesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuoteInsights(),
        backgroundColor: const Color(0xFF006B3C),
        icon: const Icon(Icons.analytics, color: Colors.white),
        label: const Text('Insights', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPendingQuotesTab() {
    if (_pendingQuotes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending quote requests'),
            Text('New requests will appear here'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingQuotes.length,
      itemBuilder: (context, index) {
        final quote = _pendingQuotes[index];
        return _buildPendingQuoteCard(quote);
      },
    );
  }

  Widget _buildPendingQuoteCard(Map<String, dynamic> quote) {
    final timeAgo = _getTimeAgo(quote['timestamp']);
    final isUrgent = quote['urgency'].toString().contains('Emergency') || 
                     quote['urgency'].toString().contains('Urgent');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? Colors.red.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
          width: isUrgent ? 2 : 1,
        ),
        color: isUrgent ? Colors.red.withValues(alpha: 0.05) : null,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: isUrgent ? 4 : 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with customer and urgency
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF006B3C),
                    child: Text(
                      quote['customer'][0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote['customer'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${quote['service']} • $timeAgo',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                quote['description'],
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 8),
              
              // Location and budget
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      quote['location'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quote['budget'],
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              
              if (quote['photos'] > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.camera_alt, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${quote['photos']} photos attached',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _viewQuoteDetails(quote),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _createQuote(quote),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Quote Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveQuotesTab() {
    if (_activeQuotes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active quotes'),
            Text('Your submitted quotes will appear here'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeQuotes.length,
      itemBuilder: (context, index) {
        final quote = _activeQuotes[index];
        return _buildActiveQuoteCard(quote);
      },
    );
  }

  Widget _buildActiveQuoteCard(Map<String, dynamic> quote) {
    final validUntil = DateFormat('MMM dd, yyyy').format(quote['validUntil']);
    final isExpiringSoon = quote['validUntil'].difference(DateTime.now()).inHours < 24;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF006B3C),
                    child: Text(
                      quote['customer'][0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote['customer'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          quote['service'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₵${quote['myQuote']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      Text(
                        quote['estimatedDuration'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(quote['description']),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      quote['location'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Quote validity
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpiringSoon ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isExpiringSoon ? Colors.orange : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpiringSoon ? Icons.timer : Icons.schedule,
                      size: 16,
                      color: isExpiringSoon ? Colors.orange : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isExpiringSoon ? 'Expires soon: $validUntil' : 'Valid until: $validUntil',
                      style: TextStyle(
                        color: isExpiringSoon ? Colors.orange : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _editQuote(quote),
                      child: const Text('Edit Quote'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _followUpQuote(quote),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Follow Up'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedQuotesTab() {
    if (_completedQuotes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No completed quotes'),
            Text('Your completed jobs will appear here'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedQuotes.length,
      itemBuilder: (context, index) {
        final quote = _completedQuotes[index];
        return _buildCompletedQuoteCard(quote);
      },
    );
  }

  Widget _buildCompletedQuoteCard(Map<String, dynamic> quote) {
    final completedDate = DateFormat('MMM dd, yyyy').format(quote['completedAt']);
    final isAccepted = quote['status'] == 'accepted' || quote['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isAccepted ? Colors.green : Colors.grey,
                    child: Icon(
                      isAccepted ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote['customer'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${quote['service']} • $completedDate',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isAccepted) ...[
                        Text(
                          '+₵${quote['earnings'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (quote['customerRating'] != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              Text(
                                quote['customerRating'].toString(),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                      ] else ...[
                        const Text(
                          'Not Selected',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(quote['description']),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      quote['location'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ],
              ),
              
              if (isAccepted) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Job Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('₵${quote['finalPrice']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Your Earnings', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('₵${quote['earnings'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _viewQuoteDetails(Map<String, dynamic> quote) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quote Request Details',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Customer info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF006B3C),
                    child: Text(quote['customer'][0], style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quote['customer'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(quote['service'], style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Service details
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Description', quote['description']),
                      _buildDetailRow('Location', quote['location']),
                      _buildDetailRow('Urgency', quote['urgency']),
                      _buildDetailRow('Budget', quote['budget']),
                      
                      if (quote['details'] != null) ...[
                        const SizedBox(height: 16),
                        const Text('Specific Requirements:', 
                                 style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...quote['details'].entries.map((entry) {
                          return _buildDetailRow(entry.key, entry.value.toString());
                        }).toList(),
                      ],
                      
                      if (quote['photos'] > 0) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.photo, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text('${quote['photos']} photos available'),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _viewPhotos(quote),
                              child: const Text('View Photos'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _createQuote(quote);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Quote'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _createQuote(Map<String, dynamic> quote) {
    final TextEditingController priceController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quote for ${quote['customer']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Service: ${quote['service']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Your Quote (GH₵)',
                  border: OutlineInputBorder(),
                  prefixText: '₵',
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Duration',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 2-3 hours',
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Any specific details or requirements...',
                ),
              ),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 Quote Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('• Be competitive but fair'),
                    Text('• Include all materials/transport'),
                    Text('• Respond quickly for urgent requests'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (priceController.text.isNotEmpty && durationController.text.isNotEmpty) {
                _submitQuote(quote, priceController.text, durationController.text, notesController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Quote'),
          ),
        ],
      ),
    );
  }

  void _submitQuote(Map<String, dynamic> quote, String price, String duration, String notes) {
    setState(() {
      _pendingQuotes.remove(quote);
      _activeQuotes.add({
        ...quote,
        'myQuote': int.parse(price),
        'quotedAt': DateTime.now(),
        'status': 'quoted',
        'estimatedDuration': duration,
        'validUntil': DateTime.now().add(const Duration(days: 7)),
        'notes': notes,
      });
    });

    // Send notification to customer
    NotificationService().sendQuoteUpdateNotification(
      quoteId: quote['id'],
      customerName: quote['customer'],
      status: 'submitted',
      amount: double.parse(price),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editQuote(Map<String, dynamic> quote) {
    // Implementation for editing existing quotes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit quote feature - Coming soon!')),
    );
  }

  void _followUpQuote(Map<String, dynamic> quote) {
    // Send follow-up notification to customer
    NotificationService().sendQuoteUpdateNotification(
      quoteId: quote['id'],
      customerName: quote['customer'],
      status: 'follow_up',
      amount: quote['myQuote'].toDouble(),
    );

    // Set reminder for provider
    NotificationService().sendServiceReminderNotification(
      serviceId: quote['id'],
      serviceName: quote['service'],
      reminderType: 'follow_up',
      scheduledTime: DateTime.now().add(const Duration(days: 2)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Follow up sent to customer!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewPhotos(Map<String, dynamic> quote) {
    // Implementation for viewing attached photos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo viewer - Coming soon!')),
    );
  }

  void _showQuoteInsights() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quote Insights'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInsightCard('Total Quotes Sent', '12', Icons.send, Colors.blue),
              const SizedBox(height: 12),
              _buildInsightCard('Acceptance Rate', '75%', Icons.trending_up, Colors.green),
              const SizedBox(height: 12),
              _buildInsightCard('Avg Response Time', '2.3 hrs', Icons.schedule, Colors.orange),
              const SizedBox(height: 12),
              _buildInsightCard('This Month Earnings', '₵1,450', Icons.account_balance_wallet, Colors.purple),
            ],
          ),
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

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}