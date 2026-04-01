// Admin Configuration
// IMPORTANT: Keep this file secure and do not commit the actual secret code to public repositories

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminConfig {
  // Admin secret code loaded from .env file for security
  // This code is required when registering as an admin
  static String get ADMIN_SECRET_CODE => dotenv.env['ADMIN_SECRET_CODE'] ?? '';

  // Allowed admin email domains (optional - set to null to allow any email)
  // Example: ['@homelink.gh', '@homelinkgh.com']
  static const List<String>? ALLOWED_ADMIN_DOMAINS = ['@homelink.gh', '@homelinkgh.com'];

  // Maximum number of admin accounts allowed
  static const int MAX_ADMIN_ACCOUNTS = 10;

  // Require existing admin approval for new admin accounts
  // Set to false for the first admin, then true for subsequent admins
  static const bool REQUIRE_ADMIN_APPROVAL = false;

  // Specific email addresses that are pre-approved as admins
  static const List<String> PREAPPROVED_ADMIN_EMAILS = [
    // Add your admin emails here
    // 'your.email@homelink.gh',
  ];

  /// Validates if the provided secret code is correct
  static bool validateSecretCode(String code) {
    return code == ADMIN_SECRET_CODE;
  }

  /// Validates if the email domain is allowed for admin registration
  static bool validateEmailDomain(String email) {
    if (ALLOWED_ADMIN_DOMAINS == null || ALLOWED_ADMIN_DOMAINS!.isEmpty) {
      return true; // Allow any domain if not configured
    }

    final emailLower = email.toLowerCase();
    return ALLOWED_ADMIN_DOMAINS!.any((domain) =>
      emailLower.endsWith(domain.toLowerCase())
    );
  }

  /// Checks if email is pre-approved for admin access
  static bool isEmailPreapproved(String email) {
    return PREAPPROVED_ADMIN_EMAILS.contains(email.toLowerCase());
  }
}
