import 'package:flutter/material.dart';
import '../models/saved_payment_method.dart';
import '../services/saved_payment_service.dart';

/// Saved Payment Methods Screen
/// Allows users to manage their saved payment methods
class SavedPaymentMethodsScreen extends StatefulWidget {
  final String userId;

  const SavedPaymentMethodsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SavedPaymentMethodsScreen> createState() => _SavedPaymentMethodsScreenState();
}

class _SavedPaymentMethodsScreenState extends State<SavedPaymentMethodsScreen> {
  final _savedPaymentService = SavedPaymentService();
  List<SavedPaymentMethod> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);
    try {
      final methods = await _savedPaymentService.getSavedPaymentMethods(widget.userId);
      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading payment methods: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load payment methods', isError: true);
    }
  }

  Future<void> _deletePaymentMethod(SavedPaymentMethod method) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${method.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _savedPaymentService.deletePaymentMethod(method.id);
      _showSnackBar('Payment method deleted');
      await _loadPaymentMethods();
    } catch (e) {
      _showSnackBar('Failed to delete payment method', isError: true);
    }
  }

  Future<void> _setDefaultPaymentMethod(SavedPaymentMethod method) async {
    try {
      await _savedPaymentService.setDefaultPaymentMethod(widget.userId, method.id);
      _showSnackBar('${method.displayName} set as default');
      await _loadPaymentMethods();
    } catch (e) {
      _showSnackBar('Failed to set default payment method', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _paymentMethods.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPaymentMethods,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = _paymentMethods[index];
                      return _buildPaymentMethodCard(method);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add payment method screen (would integrate with payment flow)
          _showSnackBar('Add a payment during checkout to save it', isError: false);
        },
        backgroundColor: Color(0xFF00A651),
        icon: Icon(Icons.add),
        label: Text('Add Payment Method'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No saved payment methods',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Save a payment method during checkout\nfor faster future payments',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
            label: Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00A651),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(SavedPaymentMethod method) {
    final isExpired = method.type == 'card' && method.isExpired;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFF00A651).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      method.icon,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Payment method info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              method.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (method.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF00A651),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      if (method.type == 'card' && method.expiryMonth != null && method.expiryYear != null)
                        Text(
                          'Expires ${method.expiryMonth}/${method.expiryYear}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isExpired ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      if (method.type == 'momo' && method.phoneNumber != null)
                        Text(
                          method.phoneNumber!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      SizedBox(height: 2),
                      Text(
                        'Last used ${_formatLastUsed(method.lastUsed)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (isExpired)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'This card has expired',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 8),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!method.isDefault && !isExpired)
                  TextButton.icon(
                    onPressed: () => _setDefaultPaymentMethod(method),
                    icon: Icon(Icons.star_border, size: 18),
                    label: Text('Set as Default'),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF00A651),
                    ),
                  ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deletePaymentMethod(method),
                  icon: Icon(Icons.delete_outline, size: 18),
                  label: Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastUsed(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'just now';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    }
  }
}
