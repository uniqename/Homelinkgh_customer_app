import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  String selectedFilter = 'all';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.work;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Waiting for Provider';
      case 'confirmed':
        return 'Provider Confirmed';
      case 'in_progress':
        return 'Work in Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Widget _buildBookingCard(DocumentSnapshot booking) {
    final data = booking.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'pending';
    final scheduledDate = (data['scheduledDate'] as Timestamp?)?.toDate();
    final priceGHS = data['priceGHS']?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data['serviceType'] ?? 'Service',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 14,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusDisplayText(status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      data['address'] ?? 'No address provided',
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (scheduledDate != null) ...[
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year} at ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  const Icon(Icons.payments, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'GH₵${priceGHS.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF006B3C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (data['paymentMethod'] != null)
                    Text(
                      data['paymentMethod'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              if (status == 'completed') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showReviewDialog(booking),
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text('Leave Review'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF006B3C),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(DocumentSnapshot booking) {
    final data = booking.data() as Map<String, dynamic>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['serviceType'] ?? 'Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', _getStatusDisplayText(data['status'] ?? 'pending')),
              _buildDetailRow('Address', data['address'] ?? 'Not provided'),
              _buildDetailRow('Price', 'GH₵${(data['priceGHS']?.toDouble() ?? 0.0).toStringAsFixed(0)}'),
              if (data['paymentMethod'] != null)
                _buildDetailRow('Payment', data['paymentMethod']),
              if (data['description'] != null && data['description'].toString().isNotEmpty)
                _buildDetailRow('Description', data['description']),
              if (data['scheduledDate'] != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Scheduled', 
                  '${(data['scheduledDate'] as Timestamp).toDate().day}/${(data['scheduledDate'] as Timestamp).toDate().month}/${(data['scheduledDate'] as Timestamp).toDate().year}'
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (data['status'] == 'pending')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelBooking(booking.id);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(DocumentSnapshot booking) {
    final reviewController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rate your experience:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      rating = index + 1.0;
                    });
                  },
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(
                labelText: 'Your review (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _submitReview(booking.id, rating, reviewController.text);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview(String bookingId, double rating, String comment) async {
    try {
      await FirebaseService.reviews.add({
        'bookingId': bookingId,
        'customerId': FirebaseAuth.instance.currentUser?.uid,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await FirebaseService.bookings.doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Please log in to view your bookings'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Bookings')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: selectedFilter == 'all'
            ? FirebaseService.getUserBookings(user.uid)
            : FirebaseService.bookings
                .where('customerId', isEqualTo: user.uid)
                .where('status', isEqualTo: selectedFilter)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data?.docs ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    selectedFilter == 'all' 
                        ? 'No bookings yet'
                        : 'No $selectedFilter bookings',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your service bookings will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(bookings[index]);
            },
          );
        },
      ),
    );
  }
}