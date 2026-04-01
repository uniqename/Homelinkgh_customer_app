import 'package:flutter/material.dart';
import '../models/saved_payment_method.dart';
import '../services/firebase_service.dart';
import '../services/payment_service.dart';

/// Saved Payment Service for HomeLinkGH
/// Manages tokenized payment methods for faster checkout
class SavedPaymentService {
  final _firebaseService = FirebaseService();
  final _paymentService = PaymentService();

  /// Save a new payment method after successful payment
  Future<String> savePaymentMethod({
    required String userId,
    required String type,
    required String token,
    required String last4,
    required String brand,
    String? expiryMonth,
    String? expiryYear,
    String? phoneNumber,
    String? cardholderName,
    bool isDefault = false,
  }) async {
    try {
      // If this is set as default, unset all other defaults first
      if (isDefault) {
        await _unsetAllDefaultMethods(userId);
      }

      final paymentMethod = SavedPaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: type,
        token: token,
        last4: last4,
        brand: brand,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        phoneNumber: phoneNumber,
        cardholderName: cardholderName,
        isDefault: isDefault,
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );

      await _firebaseService.createSavedPaymentMethod(paymentMethod);
      return paymentMethod.id;
    } catch (e) {
      throw Exception('Failed to save payment method: $e');
    }
  }

  /// Get all saved payment methods for a user
  Future<List<SavedPaymentMethod>> getSavedPaymentMethods(String userId) async {
    try {
      final methods = await _firebaseService.getSavedPaymentMethods(userId);

      // Sort: default first, then by last used
      methods.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return b.lastUsed.compareTo(a.lastUsed);
      });

      return methods;
    } catch (e) {
      throw Exception('Failed to get saved payment methods: $e');
    }
  }

  /// Get a specific payment method by ID
  Future<SavedPaymentMethod?> getPaymentMethod(String paymentMethodId) async {
    try {
      return await _firebaseService.getSavedPaymentMethod(paymentMethodId);
    } catch (e) {
      throw Exception('Failed to get payment method: $e');
    }
  }

  /// Delete a saved payment method
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _firebaseService.deleteSavedPaymentMethod(paymentMethodId);
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  /// Set a payment method as default
  Future<void> setDefaultPaymentMethod(String userId, String paymentMethodId) async {
    try {
      // First, unset all defaults for this user
      await _unsetAllDefaultMethods(userId);

      // Then set the selected method as default
      final method = await getPaymentMethod(paymentMethodId);
      if (method != null) {
        final updatedMethod = method.copyWith(isDefault: true);
        await _firebaseService.updateSavedPaymentMethod(
          paymentMethodId,
          updatedMethod.toMap(),
        );
      }
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  /// Update last used timestamp
  Future<void> updateLastUsed(String paymentMethodId) async {
    try {
      await _firebaseService.updateSavedPaymentMethod(
        paymentMethodId,
        {'lastUsed': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw Exception('Failed to update last used: $e');
    }
  }

  /// Process payment using a saved payment method
  Future<Map<String, dynamic>> payWithSavedMethod({
    required BuildContext context,
    required String paymentMethodId,
    required double amount,
    required String description,
    String currency = 'GHS',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get the saved payment method
      final method = await getPaymentMethod(paymentMethodId);
      if (method == null) {
        throw Exception('Payment method not found');
      }

      // Check if card is expired (for card payments)
      if (method.type == 'card' && method.isExpired) {
        throw Exception('Card has expired. Please update or use a different payment method.');
      }

      // Process payment using the saved token
      final result = await _paymentService.chargeTokenizedPayment(
        token: method.token,
        amount: amount,
        currency: currency,
        description: description,
        email: metadata?['email'] ?? '',
      );

      // Update last used timestamp
      await updateLastUsed(paymentMethodId);

      return result;
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }

  /// Check if user has any saved payment methods
  Future<bool> hasSavedMethods(String userId) async {
    try {
      final methods = await getSavedPaymentMethods(userId);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get default payment method for user
  Future<SavedPaymentMethod?> getDefaultPaymentMethod(String userId) async {
    try {
      final methods = await getSavedPaymentMethods(userId);
      return methods.firstWhere(
        (m) => m.isDefault,
        orElse: () => methods.isNotEmpty ? methods.first : throw Exception('No methods'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Unset all default payment methods for a user (internal helper)
  Future<void> _unsetAllDefaultMethods(String userId) async {
    try {
      final methods = await getSavedPaymentMethods(userId);
      for (var method in methods.where((m) => m.isDefault)) {
        final updated = method.copyWith(isDefault: false);
        await _firebaseService.updateSavedPaymentMethod(
          method.id,
          updated.toMap(),
        );
      }
    } catch (e) {
      // Log error but don't throw - this is a helper method
      print('Error unsetting default methods: $e');
    }
  }

  /// Validate if a payment method can be used (not expired, token still valid)
  Future<bool> validatePaymentMethod(String paymentMethodId) async {
    try {
      final method = await getPaymentMethod(paymentMethodId);
      if (method == null) return false;

      // Check expiry for cards
      if (method.type == 'card' && method.isExpired) {
        return false;
      }

      // Could add token validation with Flutterwave API here
      return true;
    } catch (e) {
      return false;
    }
  }
}
