export 'chat_screen.dart';

/// Legacy chat.dart file - now exports the full chat_screen.dart implementation
/// 
/// This maintains backward compatibility while providing the new real-time chat functionality.
/// All chat-related functionality has been moved to chat_screen.dart with comprehensive features:
/// 
/// Features included:
/// - Real-time messaging with Firebase
/// - Message status indicators (sent/delivered/read)
/// - System messages for booking status updates
/// - Location sharing capabilities
/// - Image sharing support
/// - Provider/customer live tracking integration
/// - Quick action buttons for common tasks
/// - Unread message counts and notifications
/// - Professional UI with HomeLinkGH branding
/// 
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => ChatScreen(
///       bookingId: 'booking_123',
///       currentUserId: 'user_456', 
///       currentUserType: 'customer', // or 'provider'
///       currentUserName: 'John Doe',
///     ),
///   ),
/// );
/// ```