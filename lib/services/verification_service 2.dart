import 'dart:io';
import 'package:flutter/material.dart';

class VerificationService {
  static const String _verificationEndpoint = 'https://api.homelinkgh.com/verify';
  
  // Ghana Card verification for local workers and customers
  static Future<Map<String, dynamic>> verifyGhanaCard({
    required String cardNumber,
    required String fullName,
    required DateTime dateOfBirth,
    File? cardImage,
  }) async {
    try {
      // Simulate API call to Ghana Card verification service
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic format validation for Ghana Card
      if (!_isValidGhanaCardFormat(cardNumber)) {
        return {
          'success': false,
          'error': 'Invalid Ghana Card format. Should be GHA-XXXXXXXXX-X',
          'verified': false,
        };
      }
      
      // In a real implementation, this would connect to the official Ghana Card API
      // For now, we'll simulate a successful verification
      return {
        'success': true,
        'verified': true,
        'cardNumber': cardNumber,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'verificationDate': DateTime.now().toIso8601String(),
        'trustScore': 95, // High trust score for Ghana Card
        'verificationMethod': 'Ghana Card',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verification service temporarily unavailable: $e',
        'verified': false,
      };
    }
  }
  
  // Driver's License verification for diaspora customers
  static Future<Map<String, dynamic>> verifyDriversLicense({
    required String licenseNumber,
    required String fullName,
    required String issuingCountry,
    required String issuingState, // For US, Canada, etc.
    File? licenseImage,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic validation
      if (licenseNumber.length < 5) {
        return {
          'success': false,
          'error': 'Invalid license number format',
          'verified': false,
        };
      }
      
      // Simulate verification based on issuing country
      final supportedCountries = ['US', 'UK', 'Canada', 'Germany', 'Netherlands'];
      if (!supportedCountries.contains(issuingCountry)) {
        return {
          'success': false,
          'error': 'Driver\'s license verification not yet supported for $issuingCountry',
          'verified': false,
        };
      }
      
      return {
        'success': true,
        'verified': true,
        'licenseNumber': licenseNumber,
        'fullName': fullName,
        'issuingCountry': issuingCountry,
        'issuingState': issuingState,
        'verificationDate': DateTime.now().toIso8601String(),
        'trustScore': 85, // Slightly lower trust score for international docs
        'verificationMethod': 'Driver\'s License',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verification service temporarily unavailable: $e',
        'verified': false,
      };
    }
  }
  
  // Enhanced background check for sensitive services (babysitting, adult care)
  static Future<Map<String, dynamic>> performBackgroundCheck({
    required String identificationNumber,
    required String fullName,
    required String verificationType, // 'ghana_card' or 'drivers_license'
    bool requiresCriminalCheck = false,
    bool requiresReferenceCheck = false,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      
      final results = <String, dynamic>{
        'identityVerified': true,
        'criminalCheckPassed': true,
        'referencesVerified': true,
        'trustScore': 90,
        'verificationDate': DateTime.now().toIso8601String(),
        'checks': <String>[],
      };
      
      // Identity verification
      Map<String, dynamic> identityResult;
      if (verificationType == 'ghana_card') {
        identityResult = await verifyGhanaCard(
          cardNumber: identificationNumber,
          fullName: fullName,
          dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // Assume 25 years old
        );
      } else {
        identityResult = await verifyDriversLicense(
          licenseNumber: identificationNumber,
          fullName: fullName,
          issuingCountry: 'US', // Default for demo
          issuingState: 'CA',
        );
      }
      
      if (!identityResult['verified']) {
        results['identityVerified'] = false;
        results['trustScore'] = 30;
      }
      results['checks'].add('Identity Verification');
      
      // Criminal background check (simulated)
      if (requiresCriminalCheck) {
        await Future.delayed(const Duration(seconds: 1));
        // In reality, this would check criminal databases
        results['checks'].add('Criminal Background Check');
        results['criminalRecord'] = 'Clean';
      }
      
      // Reference check (simulated)
      if (requiresReferenceCheck) {
        await Future.delayed(const Duration(seconds: 1));
        results['checks'].add('Reference Verification');
        results['references'] = [
          {'name': 'Previous Employer', 'rating': 4.8, 'verified': true},
          {'name': 'Character Reference', 'rating': 4.9, 'verified': true},
        ];
      }
      
      return {
        'success': true,
        'verified': results['identityVerified'] && results['criminalCheckPassed'],
        'results': results,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Background check service temporarily unavailable: $e',
        'verified': false,
      };
    }
  }
  
  // Trust score calculation
  static int calculateTrustScore({
    required bool identityVerified,
    required String verificationType,
    bool criminalCheckPassed = true,
    bool referencesVerified = false,
    int yearsOfExperience = 0,
    double averageRating = 0.0,
  }) {
    int score = 0;
    
    // Base score for identity verification
    if (identityVerified) {
      score += verificationType == 'ghana_card' ? 40 : 35; // Ghana Card gets higher base score
    }
    
    // Criminal check
    if (criminalCheckPassed) {
      score += 25;
    }
    
    // References
    if (referencesVerified) {
      score += 15;
    }
    
    // Experience bonus
    score += (yearsOfExperience * 2).clamp(0, 10);
    
    // Rating bonus
    if (averageRating > 0) {
      score += (averageRating * 2).round().clamp(0, 10);
    }
    
    return score.clamp(0, 100);
  }
  
  // Helper method to validate Ghana Card format
  static bool _isValidGhanaCardFormat(String cardNumber) {
    // Ghana Card format: GHA-XXXXXXXXX-X (where X is digit)
    final regex = RegExp(r'^GHA-\d{9}-\d$');
    return regex.hasMatch(cardNumber);
  }
  
  // Get verification requirements for specific services
  static Map<String, dynamic> getVerificationRequirements(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'babysitting':
        return {
          'identityRequired': true,
          'criminalCheckRequired': true,
          'referencesRequired': true,
          'minimumTrustScore': 85,
          'description': 'Comprehensive background check required for child safety',
          'requiredDocuments': ['Valid ID', 'Criminal Background Check', 'Character References'],
        };
      
      case 'adult sitter':
        return {
          'identityRequired': true,
          'criminalCheckRequired': true,
          'referencesRequired': true,
          'minimumTrustScore': 80,
          'description': 'Thorough verification required for elder care services',
          'requiredDocuments': ['Valid ID', 'Background Check', 'Medical Training Certificate (preferred)'],
        };
      
      case 'cleaning':
      case 'laundry':
        return {
          'identityRequired': true,
          'criminalCheckRequired': false,
          'referencesRequired': true,
          'minimumTrustScore': 70,
          'description': 'Identity verification and references required',
          'requiredDocuments': ['Valid ID', 'Work References'],
        };
      
      case 'food delivery':
      case 'grocery':
        return {
          'identityRequired': true,
          'criminalCheckRequired': false,
          'referencesRequired': false,
          'minimumTrustScore': 60,
          'description': 'Basic identity verification required',
          'requiredDocuments': ['Valid ID'],
        };
      
      default:
        return {
          'identityRequired': true,
          'criminalCheckRequired': false,
          'referencesRequired': false,
          'minimumTrustScore': 65,
          'description': 'Standard identity verification required',
          'requiredDocuments': ['Valid ID'],
        };
    }
  }
}

// Widget for verification status display
class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final int trustScore;
  final String verificationType;
  
  const VerificationBadge({
    super.key,
    required this.isVerified,
    required this.trustScore,
    required this.verificationType,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = isVerified ? _getTrustColor(trustScore) : Colors.grey;
    final icon = isVerified ? Icons.verified : Icons.pending;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            isVerified ? '$verificationType Verified ($trustScore%)' : 'Pending Verification',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getTrustColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}