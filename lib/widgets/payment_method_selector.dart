import 'package:flutter/material.dart';
import '../models/saved_payment_method.dart';
import '../services/saved_payment_service.dart';

/// Payment Method Selector Widget
/// Used during checkout to select a saved payment method or add new one
class PaymentMethodSelector extends StatefulWidget {
  final String userId;
  final Function(SavedPaymentMethod?) onMethodSelected;
  final bool allowAddNew;

  const PaymentMethodSelector({
    super.key,
    required this.userId,
    required this.onMethodSelected,
    this.allowAddNew = true,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  final _savedPaymentService = SavedPaymentService();
  List<SavedPaymentMethod> _paymentMethods = [];
  SavedPaymentMethod? _selectedMethod;
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
        // Auto-select default method if available
        if (methods.isNotEmpty) {
          _selectedMethod = methods.firstWhere(
            (m) => m.isDefault,
            orElse: () => methods.first,
          );
        } else {
          _selectedMethod = null;
        }
        _isLoading = false;
      });

      // Notify parent of auto-selection
      if (_selectedMethod != null) {
        widget.onMethodSelected(_selectedMethod);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _selectMethod(SavedPaymentMethod? method) {
    setState(() {
      _selectedMethod = method;
    });
    widget.onMethodSelected(method);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),

        // Saved payment methods
        if (_paymentMethods.isNotEmpty)
          ..._paymentMethods.map((method) => _buildMethodCard(method)),

        // Add new payment method option
        if (widget.allowAddNew)
          _buildAddNewCard(),

        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMethodCard(SavedPaymentMethod method) {
    final isSelected = _selectedMethod?.id == method.id;
    final isExpired = method.type == 'card' && method.isExpired;

    return GestureDetector(
      onTap: isExpired ? null : () => _selectMethod(method),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpired
              ? Colors.grey[100]
              : (isSelected ? Color(0xFF00A651).withOpacity(0.1) : Colors.white),
          border: Border.all(
            color: isExpired
                ? Colors.grey[300]!
                : (isSelected ? Color(0xFF00A651) : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isExpired
                      ? Colors.grey[400]!
                      : (isSelected ? Color(0xFF00A651) : Colors.grey[400]!),
                  width: 2,
                ),
                color: isSelected ? Color(0xFF00A651) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),

            SizedBox(width: 12),

            // Payment method icon
            Text(method.icon, style: TextStyle(fontSize: 28)),

            SizedBox(width: 12),

            // Payment method details
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isExpired ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                      if (method.isDefault && !isExpired)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFF00A651),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (method.type == 'card' && method.expiryMonth != null && method.expiryYear != null)
                    Text(
                      isExpired
                          ? 'Expired ${method.expiryMonth}/${method.expiryYear}'
                          : 'Exp ${method.expiryMonth}/${method.expiryYear}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isExpired ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  if (isExpired)
                    Text(
                      'Cannot use expired card',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCard() {
    final isSelected = _selectedMethod == null;

    return GestureDetector(
      onTap: () => _selectMethod(null),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF00A651).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xFF00A651) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFF00A651) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? Color(0xFF00A651) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),

            SizedBox(width: 12),

            // Add new icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF00A651).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_card,
                color: Color(0xFF00A651),
                size: 24,
              ),
            ),

            SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Payment Method',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00A651),
                    ),
                  ),
                  Text(
                    'Credit/Debit Card or Mobile Money',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple Payment Method Selector (for bottom sheets)
class QuickPaymentMethodSelector extends StatelessWidget {
  final String userId;
  final Function(SavedPaymentMethod?) onMethodSelected;

  const QuickPaymentMethodSelector({
    super.key,
    required this.userId,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16),

          // Title
          Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          // Payment method selector
          PaymentMethodSelector(
            userId: userId,
            onMethodSelected: (method) {
              onMethodSelected(method);
              Navigator.pop(context);
            },
            allowAddNew: true,
          ),
        ],
      ),
    );
  }
}
