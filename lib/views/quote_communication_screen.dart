import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';

class QuoteCommunicationScreen extends StatefulWidget {
  final Quote quote;
  final Color serviceColor;

  const QuoteCommunicationScreen({
    super.key,
    required this.quote,
    required this.serviceColor,
  });

  @override
  State<QuoteCommunicationScreen> createState() => _QuoteCommunicationScreenState();
}

class _QuoteCommunicationScreenState extends State<QuoteCommunicationScreen> {
  final _messageController = TextEditingController();
  final _counterOfferController = TextEditingController();
  final _scrollController = ScrollController();
  final QuoteService _quoteService = QuoteService();
  bool _isNegotiating = false;

  @override
  void dispose() {
    _messageController.dispose();
    _counterOfferController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quote from ${widget.quote.providerName}'),
        backgroundColor: widget.serviceColor.withAlpha(26),
        foregroundColor: widget.serviceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showQuoteDetails,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuoteHeader(),
          Expanded(
            child: _buildMessagesSection(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildQuoteHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.serviceColor.withAlpha(26),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withAlpha(51)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.serviceColor,
                radius: 24,
                child: Text(
                  widget.quote.providerName.split(' ').map((n) => n[0]).join().substring(0, 2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.quote.providerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Quote Amount: GH₵${widget.quote.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.serviceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Status: ${widget.quote.status.toString().split('.').last.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(widget.quote.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.quote.status == QuoteStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respondToQuote(QuoteStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Decline', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showNegotiationDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Negotiate'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToQuote(QuoteStatus.accepted),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.serviceColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessagesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _quoteService.getQuoteCommunication(widget.quote.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;

        if (messages.isEmpty && widget.quote.description.isNotEmpty) {
          // Show initial quote message
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _buildInitialQuoteMessage(),
            ],
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length + 1, // +1 for initial quote
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildInitialQuoteMessage();
            }
            final message = messages[index - 1];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildInitialQuoteMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: widget.serviceColor,
            radius: 16,
            child: const Icon(Icons.receipt_long, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Quote Submitted',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(widget.quote.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: GH₵${widget.quote.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.serviceColor,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.quote.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(widget.quote.description),
                  ],
                  if (widget.quote.providerMessage != null && widget.quote.providerMessage!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.quote.providerMessage!,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  if (widget.quote.breakdown != null && widget.quote.breakdown!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Cost Breakdown:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...widget.quote.breakdown!.entries.map((entry) => 
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text('• ${entry.key}: GH₵${entry.value}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isFromCustomer = message['senderType'] == 'customer';
    final timestamp = DateTime.fromMillisecondsSinceEpoch(message['timestamp']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isFromCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromCustomer) ...[
            CircleAvatar(
              backgroundColor: widget.serviceColor,
              radius: 16,
              child: Text(
                widget.quote.providerName.split(' ').map((n) => n[0]).join().substring(0, 1),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromCustomer ? widget.serviceColor : Colors.grey.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: TextStyle(
                      color: isFromCustomer ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isFromCustomer ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromCustomer) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withAlpha(51)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _sendMessage,
            backgroundColor: widget.serviceColor,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showQuoteDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quote Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Provider', widget.quote.providerName),
              _buildDetailRow('Amount', 'GH₵${widget.quote.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Currency', widget.quote.currency),
              _buildDetailRow('Status', widget.quote.status.toString().split('.').last),
              _buildDetailRow('Created', _formatDateTime(widget.quote.createdAt)),
              if (widget.quote.expiresAt != null)
                _buildDetailRow('Expires', _formatDateTime(widget.quote.expiresAt!)),
              if (widget.quote.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.quote.description),
              ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showNegotiationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Negotiate Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current quote: GH₵${widget.quote.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: _counterOfferController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your counter offer (GH₵)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message to provider',
                hintText: 'Explain your counter offer...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _negotiateQuote();
            },
            child: const Text('Send Counter Offer'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _quoteService.sendMessage(
        quoteId: widget.quote.id,
        senderId: 'current_user_id', // Replace with actual user ID
        senderType: 'customer',
        message: _messageController.text.trim(),
      );

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _respondToQuote(QuoteStatus response) async {
    try {
      await _quoteService.respondToQuote(
        quoteId: widget.quote.id,
        response: response,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quote ${response.toString().split('.').last}ed!'),
          backgroundColor: response == QuoteStatus.accepted ? Colors.green : Colors.orange,
        ),
      );

      if (response == QuoteStatus.accepted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to respond: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _negotiateQuote() async {
    final counterOffer = double.tryParse(_counterOfferController.text);
    if (counterOffer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid counter offer amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _quoteService.respondToQuote(
        quoteId: widget.quote.id,
        response: QuoteStatus.negotiating,
        customerMessage: _messageController.text.trim(),
        counterOffer: counterOffer,
      );

      _messageController.clear();
      _counterOfferController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Counter offer sent!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send counter offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Color _getStatusColor(QuoteStatus status) {
    switch (status) {
      case QuoteStatus.pending:
        return Colors.orange;
      case QuoteStatus.accepted:
        return Colors.green;
      case QuoteStatus.rejected:
        return Colors.red;
      case QuoteStatus.expired:
        return Colors.grey;
      case QuoteStatus.withdrawn:
        return Colors.grey;
      case QuoteStatus.negotiating:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}