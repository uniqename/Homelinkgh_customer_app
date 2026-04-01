import 'package:flutter/material.dart';
import '../services/food_delivery_pricing_service.dart';

class DeliveryQuoteSelectionScreen extends StatefulWidget {
  final String restaurantName;
  final Location restaurantLocation;
  final Location customerLocation;
  final double orderValue;
  final List<Map<String, dynamic>> orderItems;
  
  const DeliveryQuoteSelectionScreen({
    super.key,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.customerLocation,
    required this.orderValue,
    required this.orderItems,
  });

  @override
  State<DeliveryQuoteSelectionScreen> createState() => _DeliveryQuoteSelectionScreenState();
}

class _DeliveryQuoteSelectionScreenState extends State<DeliveryQuoteSelectionScreen> {
  final FoodDeliveryPricingService _pricingService = FoodDeliveryPricingService();
  List<DeliveryQuote>? _deliveryQuotes;
  bool _isLoading = true;
  String _selectedUrgency = 'normal';
  DeliveryQuote? _selectedQuote;
  DateTime? _preferredDeliveryTime;

  final List<Map<String, dynamic>> _urgencyOptions = [
    {
      'value': 'normal',
      'title': 'Normal Delivery',
      'subtitle': 'Standard delivery speed',
      'icon': Icons.local_shipping,
      'color': Colors.blue,
    },
    {
      'value': 'urgent',
      'title': 'Urgent Delivery',
      'subtitle': '20% faster (+40% fee)',
      'icon': Icons.speed,
      'color': Colors.orange,
    },
    {
      'value': 'express',
      'title': 'Express Delivery',
      'subtitle': '30% faster (+80% fee)',
      'icon': Icons.flash_on,
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDeliveryQuotes();
  }

  Future<void> _loadDeliveryQuotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final quotes = await _pricingService.getDeliveryQuotes(
        restaurantId: 'restaurant_id',
        restaurantLocation: widget.restaurantLocation,
        customerLocation: widget.customerLocation,
        orderValue: widget.orderValue,
        urgencyLevel: _selectedUrgency,
        preferredDeliveryTime: _preferredDeliveryTime,
      );

      setState(() {
        _deliveryQuotes = quotes;
        _selectedQuote = quotes.isNotEmpty ? quotes.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load delivery quotes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Delivery'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildOrderSummaryCard(),
                  _buildUrgencySelector(),
                  _buildTimeSelector(),
                  _buildDeliveryQuotesSection(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.restaurantName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Order Value: GH₵${widget.orderValue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.orderItems.length} item(s)',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencySelector() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Speed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_urgencyOptions.map((option) {
              final isSelected = _selectedUrgency == option['value'];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedUrgency = option['value'];
                    });
                    _loadDeliveryQuotes();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? option['color'] : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? option['color'].withAlpha(26) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          option['icon'],
                          color: option['color'],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? option['color'] : null,
                                ),
                              ),
                              Text(
                                option['subtitle'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: option['color'],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectPreferredTime(),
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      _preferredDeliveryTime != null
                          ? 'Deliver at ${TimeOfDay.fromDateTime(_preferredDeliveryTime!).format(context)}'
                          : 'Deliver ASAP',
                    ),
                  ),
                ),
                if (_preferredDeliveryTime != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _preferredDeliveryTime = null;
                      });
                      _loadDeliveryQuotes();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryQuotesSection() {
    if (_deliveryQuotes == null || _deliveryQuotes!.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.delivery_dining, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No Delivery Providers Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sorry, no delivery providers are available for your location at this time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Delivery Providers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_deliveryQuotes!.map((quote) => _buildQuoteCard(quote))),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(DeliveryQuote quote) {
    final isSelected = _selectedQuote?.providerId == quote.providerId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedQuote = quote;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.red : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.red.withAlpha(26) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote.providerName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.red : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${quote.providerRating.toStringAsFixed(1)} (${quote.totalDeliveries}+)',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'GH₵${quote.totalCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.red : Colors.black,
                        ),
                      ),
                      Text(
                        quote.estimatedTimeText,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text(
                  'View Pricing Breakdown',
                  style: TextStyle(fontSize: 14),
                ),
                children: [
                  _buildBreakdownRow('Delivery Fee', quote.deliveryFee),
                  _buildBreakdownRow('Service Fee', quote.platformServiceFee),
                  const Divider(),
                  _buildBreakdownRow('Total', quote.totalCost, isTotal: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            'GH₵${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_selectedQuote == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(51),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Text(
          'Select a delivery provider to continue',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final totalOrderValue = widget.orderValue + _selectedQuote!.totalCost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Order Value',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'GH₵${totalOrderValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Delivery in ${_selectedQuote!.estimatedTimeText}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _proceedToPayment(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text(
              'Proceed to Payment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPreferredTime() async {
    final now = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );

    if (time != null) {
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Ensure the selected time is in the future
      if (selectedDateTime.isAfter(now.add(const Duration(minutes: 30)))) {
        setState(() {
          _preferredDeliveryTime = selectedDateTime;
        });
        _loadDeliveryQuotes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time at least 30 minutes from now'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _proceedToPayment() {
    if (_selectedQuote == null) return;

    // Here you would navigate to payment screen with the selected quote
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Proceeding with ${_selectedQuote!.providerName} - GH₵${_selectedQuote!.totalCost.toStringAsFixed(2)}',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back or to payment screen
    Navigator.pop(context, _selectedQuote);
  }
}