import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

/// Verification statuses
enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
  suspended,
  underReview,
  expired,
  promoted,
}

/// Trust levels based on verification
enum TrustLevel {
  none(0),
  basic(1),
  standard(2),
  premium(3),
  elite(4);
  
  const TrustLevel(this.value);
  final int value;
}

/// Ghana Card Verification Service for HomeLinkGH
/// Handles verification process for users and providers
class GhanaCardVerificationService {
  static const String _verificationDataKey = 'verification_data';
  static const String _pendingVerificationsKey = 'pending_verifications';
  static const String _verificationHistoryKey = 'verification_history';
  
  /// Submit Ghana Card verification
  static Future<Map<String, dynamic>> submitGhanaCardVerification({
    required String userId,
    required String fullName,
    required String ghanaCardNumber,
    required String dateOfBirth,
    required String phoneNumber,
    required XFile frontImageFile,
    required XFile backImageFile,
    XFile? selfieImageFile,
    required String userType, // 'customer', 'provider', 'admin'
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Validate Ghana Card number format
      if (!_isValidGhanaCardNumber(ghanaCardNumber)) {
        return {
          'success': false,
          'message': 'Invalid Ghana Card number format. Use format: GHA-XXXXXXXXX-X',
        };
      }
      
      // Validate phone number
      if (!_isValidGhanaPhoneNumber(phoneNumber)) {
        return {
          'success': false,
          'message': 'Invalid Ghana phone number. Use format: +233XXXXXXXXX',
        };
      }
      
      // Create verification record
      String verificationId = 'GCV_${DateTime.now().millisecondsSinceEpoch}';
      
      Map<String, dynamic> verificationData = {
        'verification_id': verificationId,
        'user_id': userId,
        'user_type': userType,
        'personal_info': {
          'full_name': fullName,
          'ghana_card_number': ghanaCardNumber,
          'date_of_birth': dateOfBirth,
          'phone_number': phoneNumber,
        },
        'documents': {
          'front_image_path': frontImageFile.path,
          'back_image_path': backImageFile.path,
          'selfie_image_path': selfieImageFile?.path,
        },
        'additional_data': additionalData ?? {},
        'status': VerificationStatus.pending.name,
        'trust_level': TrustLevel.none.name,
        'submission_date': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        'verification_attempts': 1,
        'verification_history': [],
        'flags': [],
        'admin_notes': '',
      };
      
      // Save to pending verifications
      await _savePendingVerification(verificationData);
      
      // Update user verification status
      await _updateUserVerificationStatus(userId, VerificationStatus.pending);
      
      return {
        'success': true,
        'verification_id': verificationId,
        'message': 'Ghana Card verification submitted successfully. Review typically takes 24-48 hours.',
        'status': VerificationStatus.pending.name,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit verification: $e',
      };
    }
  }
  
  /// Admin: Get all pending verifications
  static Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_pendingVerificationsKey);
      if (jsonString != null) {
        List<dynamic> decoded = json.decode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error loading pending verifications: $e');
    }
    return [];
  }
  
  /// Admin: Approve verification
  static Future<Map<String, dynamic>> approveVerification({
    required String verificationId,
    required String adminId,
    required TrustLevel assignedTrustLevel,
    String? adminNotes,
    Map<String, dynamic>? additionalBenefits,
  }) async {
    try {
      List<Map<String, dynamic>> pendingVerifications = await getPendingVerifications();
      
      // Find verification
      int index = pendingVerifications.indexWhere(
        (v) => v['verification_id'] == verificationId,
      );
      
      if (index == -1) {
        return {
          'success': false,
          'message': 'Verification record not found',
        };
      }
      
      Map<String, dynamic> verification = pendingVerifications[index];
      
      // Update verification status
      verification['status'] = VerificationStatus.verified.name;
      verification['trust_level'] = assignedTrustLevel.name;
      verification['last_updated'] = DateTime.now().toIso8601String();
      verification['approved_by'] = adminId;
      verification['approved_date'] = DateTime.now().toIso8601String();
      verification['admin_notes'] = adminNotes ?? '';
      verification['additional_benefits'] = additionalBenefits ?? {};
      
      // Add to history
      verification['verification_history'].add({
        'action': 'approved',
        'admin_id': adminId,
        'timestamp': DateTime.now().toIso8601String(),
        'trust_level': assignedTrustLevel.name,
        'notes': adminNotes,
      });
      
      // Update user verification status
      await _updateUserVerificationStatus(verification['user_id'], VerificationStatus.verified);
      
      // Save back to pending (to maintain record) and archive
      pendingVerifications[index] = verification;
      await _savePendingVerifications(pendingVerifications);
      await _archiveVerification(verification);
      
      // Calculate trust score
      double trustScore = _calculateTrustScore(verification, assignedTrustLevel);
      
      return {
        'success': true,
        'message': 'Verification approved successfully',
        'trust_level': assignedTrustLevel.name,
        'trust_score': trustScore,
        'user_id': verification['user_id'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to approve verification: $e',
      };
    }
  }
  
  /// Admin: Reject verification
  static Future<Map<String, dynamic>> rejectVerification({
    required String verificationId,
    required String adminId,
    required String rejectionReason,
    String? adminNotes,
    bool allowResubmission = true,
  }) async {
    try {
      List<Map<String, dynamic>> pendingVerifications = await getPendingVerifications();
      
      int index = pendingVerifications.indexWhere(
        (v) => v['verification_id'] == verificationId,
      );
      
      if (index == -1) {
        return {
          'success': false,
          'message': 'Verification record not found',
        };
      }
      
      Map<String, dynamic> verification = pendingVerifications[index];
      
      verification['status'] = VerificationStatus.rejected.name;
      verification['last_updated'] = DateTime.now().toIso8601String();
      verification['rejected_by'] = adminId;
      verification['rejected_date'] = DateTime.now().toIso8601String();
      verification['rejection_reason'] = rejectionReason;
      verification['admin_notes'] = adminNotes ?? '';
      verification['allow_resubmission'] = allowResubmission;
      
      verification['verification_history'].add({
        'action': 'rejected',
        'admin_id': adminId,
        'timestamp': DateTime.now().toIso8601String(),
        'reason': rejectionReason,
        'notes': adminNotes,
      });
      
      await _updateUserVerificationStatus(verification['user_id'], VerificationStatus.rejected);
      
      pendingVerifications[index] = verification;
      await _savePendingVerifications(pendingVerifications);
      
      return {
        'success': true,
        'message': 'Verification rejected',
        'rejection_reason': rejectionReason,
        'allow_resubmission': allowResubmission,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to reject verification: $e',
      };
    }
  }
  
  /// Admin: Suspend verified user
  static Future<Map<String, dynamic>> suspendUser({
    required String userId,
    required String adminId,
    required String suspensionReason,
    String? adminNotes,
    DateTime? suspensionEndDate,
  }) async {
    try {
      Map<String, dynamic> suspensionData = {
        'user_id': userId,
        'suspended_by': adminId,
        'suspension_date': DateTime.now().toIso8601String(),
        'suspension_end_date': suspensionEndDate?.toIso8601String(),
        'reason': suspensionReason,
        'admin_notes': adminNotes ?? '',
        'is_active': true,
      };
      
      await _updateUserVerificationStatus(userId, VerificationStatus.suspended);
      await _addVerificationHistory(userId, 'suspended', adminId, suspensionReason);
      
      return {
        'success': true,
        'message': 'User suspended successfully',
        'suspension_data': suspensionData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to suspend user: $e',
      };
    }
  }
  
  /// Admin: Promote user trust level
  static Future<Map<String, dynamic>> promoteUserTrustLevel({
    required String userId,
    required String adminId,
    required TrustLevel newTrustLevel,
    String? promotionReason,
    Map<String, dynamic>? additionalBenefits,
  }) async {
    try {
      Map<String, dynamic>? userData = await getUserVerificationData(userId);
      if (userData == null) {
        return {
          'success': false,
          'message': 'User verification data not found',
        };
      }
      
      TrustLevel currentLevel = TrustLevel.values.firstWhere(
        (level) => level.name == userData['trust_level'],
        orElse: () => TrustLevel.none,
      );
      
      if (newTrustLevel.value <= currentLevel.value) {
        return {
          'success': false,
          'message': 'New trust level must be higher than current level',
        };
      }
      
      userData['trust_level'] = newTrustLevel.name;
      userData['last_updated'] = DateTime.now().toIso8601String();
      userData['promoted_by'] = adminId;
      userData['promotion_date'] = DateTime.now().toIso8601String();
      userData['promotion_reason'] = promotionReason ?? '';
      userData['additional_benefits'] = additionalBenefits ?? {};
      
      await _saveUserVerificationData(userId, userData);
      await _addVerificationHistory(userId, 'promoted', adminId, 'Trust level upgraded to ${newTrustLevel.name}');
      
      return {
        'success': true,
        'message': 'User promoted to ${newTrustLevel.name} trust level',
        'new_trust_level': newTrustLevel.name,
        'benefits': _getTrustLevelBenefits(newTrustLevel),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to promote user: $e',
      };
    }
  }
  
  /// Get user verification status and data
  static Future<Map<String, dynamic>?> getUserVerificationData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('${_verificationDataKey}_$userId');
      if (jsonString != null) {
        return json.decode(jsonString);
      }
    } catch (e) {
      print('Error loading user verification data: $e');
    }
    return null;
  }
  
  /// Get verification statistics for admin dashboard
  static Future<Map<String, dynamic>> getVerificationStatistics() async {
    try {
      List<Map<String, dynamic>> pendingVerifications = await getPendingVerifications();
      
      int totalPending = pendingVerifications.length;
      int totalVerified = 0;
      int totalRejected = 0;
      int totalSuspended = 0;
      
      Map<String, int> trustLevelCounts = {};
      Map<String, int> userTypeCounts = {};
      
      for (var verification in pendingVerifications) {
        String status = verification['status'] ?? '';
        String trustLevel = verification['trust_level'] ?? '';
        String userType = verification['user_type'] ?? '';
        
        switch (status) {
          case 'verified':
            totalVerified++;
            break;
          case 'rejected':
            totalRejected++;
            break;
          case 'suspended':
            totalSuspended++;
            break;
        }
        
        trustLevelCounts[trustLevel] = (trustLevelCounts[trustLevel] ?? 0) + 1;
        userTypeCounts[userType] = (userTypeCounts[userType] ?? 0) + 1;
      }
      
      return {
        'total_pending': totalPending,
        'total_verified': totalVerified,
        'total_rejected': totalRejected,
        'total_suspended': totalSuspended,
        'trust_level_distribution': trustLevelCounts,
        'user_type_distribution': userTypeCounts,
        'verification_rate': totalVerified / (totalVerified + totalRejected + 1) * 100,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Failed to load statistics: $e',
      };
    }
  }
  
  /// Check if user can access feature based on verification
  static Future<bool> canAccessFeature(String userId, String feature) async {
    Map<String, dynamic>? userData = await getUserVerificationData(userId);
    if (userData == null) return false;
    
    VerificationStatus status = VerificationStatus.values.firstWhere(
      (s) => s.name == userData['status'],
      orElse: () => VerificationStatus.unverified,
    );
    
    TrustLevel trustLevel = TrustLevel.values.firstWhere(
      (level) => level.name == userData['trust_level'],
      orElse: () => TrustLevel.none,
    );
    
    switch (feature) {
      case 'booking_services':
        return status == VerificationStatus.verified;
      case 'providing_services':
        return status == VerificationStatus.verified && trustLevel.value >= TrustLevel.basic.value;
      case 'high_value_transactions':
        return status == VerificationStatus.verified && trustLevel.value >= TrustLevel.standard.value;
      case 'premium_features':
        return status == VerificationStatus.verified && trustLevel.value >= TrustLevel.premium.value;
      case 'admin_features':
        return status == VerificationStatus.verified && trustLevel.value >= TrustLevel.elite.value;
      default:
        return false;
    }
  }
  
  /// Private helper methods
  static bool _isValidGhanaCardNumber(String cardNumber) {
    RegExp regex = RegExp(r'^GHA-\d{9}-\d$');
    return regex.hasMatch(cardNumber);
  }
  
  static bool _isValidGhanaPhoneNumber(String phoneNumber) {
    RegExp regex = RegExp(r'^\+233[0-9]{9}$');
    return regex.hasMatch(phoneNumber);
  }
  
  static Future<void> _savePendingVerification(Map<String, dynamic> verification) async {
    List<Map<String, dynamic>> pendingVerifications = await getPendingVerifications();
    pendingVerifications.add(verification);
    await _savePendingVerifications(pendingVerifications);
  }
  
  static Future<void> _savePendingVerifications(List<Map<String, dynamic>> verifications) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(verifications);
    await prefs.setString(_pendingVerificationsKey, jsonString);
  }
  
  static Future<void> _updateUserVerificationStatus(String userId, VerificationStatus status) async {
    Map<String, dynamic>? userData = await getUserVerificationData(userId);
    userData ??= {'user_id': userId};
    
    userData['status'] = status.name;
    userData['last_updated'] = DateTime.now().toIso8601String();
    
    await _saveUserVerificationData(userId, userData);
  }
  
  static Future<void> _saveUserVerificationData(String userId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(data);
    await prefs.setString('${_verificationDataKey}_$userId', jsonString);
  }
  
  static Future<void> _archiveVerification(Map<String, dynamic> verification) async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString(_verificationHistoryKey);
    List<Map<String, dynamic>> history = [];
    
    if (historyJson != null) {
      history = List<Map<String, dynamic>>.from(json.decode(historyJson));
    }
    
    history.add(verification);
    await prefs.setString(_verificationHistoryKey, json.encode(history));
  }
  
  static Future<void> _addVerificationHistory(String userId, String action, String adminId, String details) async {
    Map<String, dynamic>? userData = await getUserVerificationData(userId);
    if (userData != null) {
      userData['verification_history'] ??= [];
      userData['verification_history'].add({
        'action': action,
        'admin_id': adminId,
        'timestamp': DateTime.now().toIso8601String(),
        'details': details,
      });
      await _saveUserVerificationData(userId, userData);
    }
  }
  
  static double _calculateTrustScore(Map<String, dynamic> verification, TrustLevel trustLevel) {
    double baseScore = trustLevel.value * 20.0; // 0, 20, 40, 60, 80
    
    // Additional factors
    if (verification['additional_benefits']?['background_check'] == true) baseScore += 10;
    if (verification['additional_benefits']?['address_verified'] == true) baseScore += 5;
    if (verification['additional_benefits']?['phone_verified'] == true) baseScore += 5;
    
    return baseScore.clamp(0.0, 100.0);
  }
  
  static Map<String, dynamic> _getTrustLevelBenefits(TrustLevel trustLevel) {
    switch (trustLevel) {
      case TrustLevel.basic:
        return {
          'features': ['Basic booking', 'Standard support'],
          'commission_rate': 15.0,
          'priority_support': false,
        };
      case TrustLevel.standard:
        return {
          'features': ['All basic features', 'Higher value transactions', 'Provider dashboard'],
          'commission_rate': 12.0,
          'priority_support': true,
        };
      case TrustLevel.premium:
        return {
          'features': ['All standard features', 'Premium listings', 'Advanced analytics'],
          'commission_rate': 10.0,
          'priority_support': true,
          'featured_listing': true,
        };
      case TrustLevel.elite:
        return {
          'features': ['All premium features', 'Admin tools', 'Special privileges'],
          'commission_rate': 8.0,
          'priority_support': true,
          'featured_listing': true,
          'admin_access': true,
        };
      default:
        return {
          'features': ['Limited access'],
          'commission_rate': 20.0,
          'priority_support': false,
        };
    }
  }
}