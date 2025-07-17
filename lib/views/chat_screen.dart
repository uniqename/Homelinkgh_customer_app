import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homelinkgh_customer/models/location.dart';
import '../models/chat_message.dart';
import '../models/booking.dart';
import '../services/chat_service.dart';
import '../services/booking_service.dart';
import '../services/gps_tracking_service.dart';

/// Real-time chat screen for communication between customers and providers
class ChatScreen extends StatefulWidget {
  final String bookingId;
  final String currentUserId;
  final String currentUserType; // 'customer' or 'provider'
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.bookingId,
    required this.currentUserId,
    required this.currentUserType,
    required this.currentUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final BookingService _bookingService = BookingService();
  final GpsTrackingService _trackingService = GpsTrackingService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  Booking? _currentBooking;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _markMessagesAsRead();
    _loadBookingDetails();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsRead();
    }
  }

  void _loadBookingDetails() async {
    final bookingData = await _bookingService.getBookingWithDetails(widget.bookingId);
    if (bookingData != null && mounted) {
      setState(() {
        _currentBooking = bookingData['booking'];
      });
    }
  }

  void _markMessagesAsRead() {
    _chatService.markMessagesAsRead(widget.bookingId, widget.currentUserId);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildBookingStatusBanner(),
          Expanded(child: _buildMessagesArea()),
          _buildQuickActions(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF006B3C),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.currentUserType == 'customer' ? 'Chat with Provider' : 'Chat with Customer',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (_currentBooking != null)
            Text(
              _currentBooking!.serviceType,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: _showLocationOptions,
          tooltip: 'Location Actions',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'booking_details', child: Text('Booking Details')),
            const PopupMenuItem(value: 'call_support', child: Text('Call Support')),
            if (widget.currentUserType == 'provider' && _currentBooking?.status == 'in_progress')
              const PopupMenuItem(value: 'complete_service', child: Text('Complete Service')),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingStatusBanner() {
    if (_currentBooking == null) return const SizedBox.shrink();

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_currentBooking!.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Booking Pending';
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        statusText = 'Booking Accepted';
        break;
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        statusText = 'Booking Confirmed';
        break;
      case 'in_progress':
        statusColor = const Color(0xFF006B3C);
        statusIcon = Icons.play_circle;
        statusText = 'Service In Progress';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.done_all;
        statusText = 'Service Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Booking Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Status: ${_currentBooking!.status}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: statusColor.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          if (_currentBooking!.status == 'in_progress')
            TextButton.icon(
              icon: const Icon(Icons.track_changes, size: 16),
              label: const Text('Track Live', style: TextStyle(fontSize: 12)),
              onPressed: _showLiveTracking,
              style: TextButton.styleFrom(
                foregroundColor: statusColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea() {
    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.getMessagesStream(widget.bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error loading messages: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data ?? [];
        
        if (messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Start your conversation',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Send a message to begin chatting',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Mark messages as read when they load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _markMessagesAsRead();
          _scrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromCurrentUser = message.isFromUser(widget.currentUserId);
    final isSystemMessage = message.isSystemMessage;

    if (isSystemMessage) {
      return _buildSystemMessage(message);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF006B3C),
              child: Text(
                message.senderName.isNotEmpty 
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isFromCurrentUser 
                    ? const Color(0xFF006B3C)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFromCurrentUser)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isFromCurrentUser ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 2),
                  _buildMessageContent(message, isFromCurrentUser),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.displayTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: isFromCurrentUser ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      if (isFromCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead ? Colors.blue.shade200 : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF006B3C),
              child: Text(
                widget.currentUserName.isNotEmpty 
                    ? widget.currentUserName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, bool isFromCurrentUser) {
    switch (message.messageType) {
      case 'location':
        return _buildLocationMessage(message, isFromCurrentUser);
      case 'image':
        return _buildImageMessage(message, isFromCurrentUser);
      default:
        return Text(
          message.message,
          style: TextStyle(
            color: isFromCurrentUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        );
    }
  }

  Widget _buildSystemMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationMessage(ChatMessage message, bool isFromCurrentUser) {
    final metadata = message.metadata ?? {};
    final address = metadata['address'] ?? 'Shared location';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: isFromCurrentUser ? Colors.white : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address,
                style: TextStyle(
                  color: isFromCurrentUser ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.map, size: 16),
          label: const Text('View on Map'),
          onPressed: () => _showLocationOnMap(metadata),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFromCurrentUser ? Colors.white : const Color(0xFF006B3C),
            foregroundColor: isFromCurrentUser ? const Color(0xFF006B3C) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildImageMessage(ChatMessage message, bool isFromCurrentUser) {
    final metadata = message.metadata ?? {};
    final imageUrl = metadata['imageUrl'] ?? '';
    final caption = metadata['caption'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey.shade300,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey),
                      Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
        if (caption != null && caption.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            caption,
            style: TextStyle(
              color: isFromCurrentUser ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActions() {
    if (_currentBooking?.status != 'in_progress') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildQuickActionButton(
            icon: Icons.location_on,
            label: 'Share Location',
            onPressed: _shareCurrentLocation,
          ),
          const SizedBox(width: 12),
          if (widget.currentUserType == 'provider')
            _buildQuickActionButton(
              icon: Icons.check_circle,
              label: 'Complete Service',
              onPressed: _completeService,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              onChanged: (text) {
                setState(() {
                  _isTyping = text.isNotEmpty;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isTyping ? _sendMessage : _showMessageOptions,
            icon: Icon(_isTyping ? Icons.send : Icons.add),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF006B3C),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    setState(() {
      _isTyping = false;
    });

    try {
      await _chatService.sendMessage(
        bookingId: widget.bookingId,
        senderId: widget.currentUserId,
        senderName: widget.currentUserName,
        senderType: widget.currentUserType,
        message: message,
      );

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  void _shareCurrentLocation() async {
    try {
      final position = await _trackingService.getCurrentLocation();
      
      await _chatService.shareLocation(
        bookingId: widget.bookingId,
        senderId: widget.currentUserId,
        senderName: widget.currentUserName,
        senderType: widget.currentUserType,
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Current location',
      );

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share location: $e')),
        );
      }
    }
  }

  void _showLocationOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.my_location),
            title: const Text('Share Current Location'),
            onPressed: () {
              Navigator.pop(context);
              _shareCurrentLocation();
            },
          ),
          if (_currentBooking?.status == 'in_progress')
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('View Live Tracking'),
              onPressed: () {
                Navigator.pop(context);
                _showLiveTracking();
              },
            ),
        ],
      ),
    );
  }

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Share Location'),
            onPressed: () {
              Navigator.pop(context);
              _shareCurrentLocation();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Send Photo'),
            onPressed: () {
              Navigator.pop(context);
              _sendPhoto();
            },
          ),
        ],
      ),
    );
  }

  void _sendPhoto() {
    // TODO: Implement photo sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo sharing coming soon!')),
    );
  }

  void _showLocationOnMap(Map<String, dynamic> locationData) {
    final latitude = locationData['latitude'] as double?;
    final longitude = locationData['longitude'] as double?;
    final address = locationData['address'] ?? 'Shared location';
    
    if (latitude == null || longitude == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shared Location'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 64, color: Color(0xFF006B3C)),
              const SizedBox(height: 16),
              Text(
                address,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Lat: ${latitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Lng: ${longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in Maps App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B3C),
                  foregroundColor: Colors.white,
                ),
              ),
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

  void _showLiveTracking() {
    Navigator.pushNamed(
      context,
      '/live_tracking',
      arguments: {'bookingId': widget.bookingId},
    );
  }

  void _completeService() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Service'),
        content: const Text('Are you sure you want to mark this service as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _bookingService.completeService(widget.bookingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service marked as completed!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to complete service: $e')),
          );
        }
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'booking_details':
        _showBookingDetails();
        break;
      case 'call_support':
        _callSupport();
        break;
      case 'complete_service':
        _completeService();
        break;
    }
  }

  void _showBookingDetails() {
    Navigator.pushNamed(
      context,
      '/booking_details',
      arguments: {'bookingId': widget.bookingId},
    );
  }

  void _callSupport() {
    // TODO: Implement support call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support call functionality coming soon!')),
    );
  }
}