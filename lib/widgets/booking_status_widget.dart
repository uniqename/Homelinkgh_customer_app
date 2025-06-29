import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/chat_service.dart';
import '../views/booking_tracking_screen.dart';
import '../views/chat_screen.dart';

/// Widget that displays active bookings with real-time status updates
class BookingStatusWidget extends StatelessWidget {
  final String userId;
  final String userType; // 'customer' or 'provider'
  final String userName;

  const BookingStatusWidget({
    super.key,
    required this.userId,
    required this.userType,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final BookingService bookingService = BookingService();

    return StreamBuilder<List<Booking>>(
      stream: bookingService.getActiveBookingsStream(userId, userType: userType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Error loading bookings',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          );
        }

        final activeBookings = snapshot.data ?? [];

        if (activeBookings.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Color(0xFF006B3C),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Active Bookings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006B3C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activeBookings.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...activeBookings.take(3).map((booking) => _buildBookingCard(
                context,
                booking,
              )),
              if (activeBookings.length > 3)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: TextButton(
                      onPressed: () => _showAllBookings(context),
                      child: Text(
                        'View all ${activeBookings.length} bookings',
                        style: const TextStyle(color: Color(0xFF006B3C)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 50,
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStatusText(booking.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(booking.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'GH₵${booking.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildChatButton(context, booking),
              const SizedBox(width: 8),
              _buildTrackButton(context, booking),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(BuildContext context, Booking booking) {
    return StreamBuilder<int>(
      stream: _getUnreadCountStream(booking.id!),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        return GestureDetector(
          onTap: () => _openChat(context, booking),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF006B3C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackButton(BuildContext context, Booking booking) {
    return GestureDetector(
      onTap: () => _openTracking(context, booking),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.track_changes,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Stream<int> _getUnreadCountStream(String bookingId) {
    final ChatService chatService = ChatService();
    
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      return await chatService.getUnreadMessageCount(bookingId, userId);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'in_progress':
        return const Color(0xFF006B3C);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Waiting for provider';
      case 'accepted':
        return 'Accepted by provider';
      case 'confirmed':
        return 'Ready to start';
      case 'in_progress':
        return 'Service in progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  void _openChat(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          bookingId: booking.id!,
          currentUserId: userId,
          currentUserType: userType,
          currentUserName: userName,
        ),
      ),
    );
  }

  void _openTracking(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingTrackingScreen(
          bookingId: booking.id!,
          currentUserId: userId,
          currentUserType: userType,
        ),
      ),
    );
  }

  void _showAllBookings(BuildContext context) {
    // TODO: Navigate to all bookings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All bookings screen coming soon!')),
    );
  }
}

/// Simplified widget for showing just the count of active bookings
class ActiveBookingsBadge extends StatelessWidget {
  final String userId;
  final String userType;

  const ActiveBookingsBadge({
    super.key,
    required this.userId,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final BookingService bookingService = BookingService();

    return StreamBuilder<List<Booking>>(
      stream: bookingService.getActiveBookingsStream(userId, userType: userType),
      builder: (context, snapshot) {
        final activeBookings = snapshot.data ?? [];
        
        if (activeBookings.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF006B3C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${activeBookings.length} active',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}