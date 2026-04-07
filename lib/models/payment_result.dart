class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? message;
  final String? receiptUrl;
  final bool isPending;
  final Map<String, dynamic>? rawResponse;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.message,
    this.receiptUrl,
    this.isPending = false,
    this.rawResponse,
  });

  factory PaymentResult.success({
    required String transactionId,
    String? message,
    String? receiptUrl,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      message: message ?? 'Payment completed successfully',
      receiptUrl: receiptUrl,
      rawResponse: rawResponse,
    );
  }

  factory PaymentResult.failure({
    required String message,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentResult(
      success: false,
      message: message,
      rawResponse: rawResponse,
    );
  }

  factory PaymentResult.pending({
    required String transactionId,
    required String message,
  }) {
    return PaymentResult(
      success: false,
      isPending: true,
      transactionId: transactionId,
      message: message,
    );
  }

  factory PaymentResult.fromMap(Map<String, dynamic> map) {
    return PaymentResult(
      success: map['success'] as bool? ?? false,
      transactionId: map['transaction_id'] as String?,
      message: map['message'] as String?,
      receiptUrl: map['receipt_url'] as String?,
      rawResponse: map['raw_response'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'transaction_id': transactionId,
      'message': message,
      'receipt_url': receiptUrl,
      'raw_response': rawResponse,
    };
  }

  @override
  String toString() {
    return 'PaymentResult{success: $success, transactionId: $transactionId, message: $message}';
  }
}
