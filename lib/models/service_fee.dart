class ServiceFee {
  final double platformFeePercentage;
  final double minimumFee;
  final double maximumFee;
  final double processingFeePercentage;
  final double insuranceFeePercentage;
  final Map<String, double> categorySpecificFees;

  ServiceFee({
    this.platformFeePercentage = 0.15, // 15% platform fee
    this.minimumFee = 5.0, // Minimum GH₵5
    this.maximumFee = 200.0, // Maximum GH₵200
    this.processingFeePercentage = 0.025, // 2.5% payment processing
    this.insuranceFeePercentage = 0.01, // 1% insurance coverage
    this.categorySpecificFees = const {},
  });

  // Industry standard service hub revenue models
  static ServiceFee get standard => ServiceFee(
    platformFeePercentage: 0.15, // 15% is typical for service platforms
    minimumFee: 5.0,
    maximumFee: 200.0,
    processingFeePercentage: 0.025,
    insuranceFeePercentage: 0.01,
    categorySpecificFees: {
      'House Cleaning': 0.12, // Lower fee for high-volume services
      'Plumbing': 0.15,
      'Electrical Services': 0.18, // Higher fee for specialized services
      'Beauty Services': 0.12,
      'Transportation': 0.20, // Higher due to insurance needs
      'Food Delivery': 0.25, // Similar to Uber Eats/Bolt Food
      'Tutoring': 0.10, // Lower fee to encourage education
      'Gardening': 0.15,
      'Tech Support': 0.18,
      'Event Planning': 0.20,
    },
  );

  double calculatePlatformFee(double providerQuote, String serviceCategory) {
    double feePercentage = categorySpecificFees[serviceCategory] ?? platformFeePercentage;
    double calculatedFee = providerQuote * feePercentage;
    
    // Apply minimum and maximum limits
    calculatedFee = calculatedFee.clamp(minimumFee, maximumFee);
    
    return calculatedFee;
  }

  double calculateProcessingFee(double totalAmount) {
    return totalAmount * processingFeePercentage;
  }

  double calculateInsuranceFee(double totalAmount) {
    return totalAmount * insuranceFeePercentage;
  }

  ServiceFeeBreakdown calculateTotal(double providerQuote, String serviceCategory) {
    double platformFee = calculatePlatformFee(providerQuote, serviceCategory);
    double subtotal = providerQuote + platformFee;
    double processingFee = calculateProcessingFee(subtotal);
    double insuranceFee = calculateInsuranceFee(subtotal);
    double totalCustomerPrice = subtotal + processingFee + insuranceFee;

    return ServiceFeeBreakdown(
      providerQuote: providerQuote,
      platformFee: platformFee,
      processingFee: processingFee,
      insuranceFee: insuranceFee,
      totalCustomerPrice: totalCustomerPrice,
      serviceCategory: serviceCategory,
      feePercentage: categorySpecificFees[serviceCategory] ?? platformFeePercentage,
    );
  }
}

class ServiceFeeBreakdown {
  final double providerQuote;
  final double platformFee;
  final double processingFee;
  final double insuranceFee;
  final double totalCustomerPrice;
  final String serviceCategory;
  final double feePercentage;

  ServiceFeeBreakdown({
    required this.providerQuote,
    required this.platformFee,
    required this.processingFee,
    required this.insuranceFee,
    required this.totalCustomerPrice,
    required this.serviceCategory,
    required this.feePercentage,
  });

  double get totalFees => platformFee + processingFee + insuranceFee;

  String get formattedBreakdown => '''
Provider Quote: GH₵${providerQuote.toStringAsFixed(2)}
Platform Fee (${(feePercentage * 100).toStringAsFixed(1)}%): GH₵${platformFee.toStringAsFixed(2)}
Processing Fee: GH₵${processingFee.toStringAsFixed(2)}
Insurance Coverage: GH₵${insuranceFee.toStringAsFixed(2)}
Total Customer Price: GH₵${totalCustomerPrice.toStringAsFixed(2)}
''';

  Map<String, dynamic> toJson() => {
    'providerQuote': providerQuote,
    'platformFee': platformFee,
    'processingFee': processingFee,
    'insuranceFee': insuranceFee,
    'totalCustomerPrice': totalCustomerPrice,
    'serviceCategory': serviceCategory,
    'feePercentage': feePercentage,
  };
}

// How other service hubs generate revenue:
class ServiceHubRevenueModels {
  static Map<String, Map<String, dynamic>> get industryStandards => {
    'Uber/Bolt': {
      'model': 'Commission + Surge Pricing',
      'rate': '20-30% of ride fare',
      'additional': 'Booking fees, cancellation fees, surge multipliers',
      'volume': 'High volume, low margin per transaction',
    },
    'Airbnb': {
      'model': 'Double-sided fees',
      'rate': '3% from hosts + 14% from guests',
      'additional': 'Payment processing, insurance',
      'volume': 'Medium volume, higher margin',
    },
    'TaskRabbit/Thumbtack': {
      'model': 'Service provider fees',
      'rate': '15-20% commission + lead fees',
      'additional': 'Background check fees, promoted listings',
      'volume': 'Medium volume, higher value transactions',
    },
    'Fiverr/Upwork': {
      'model': 'Sliding commission scale',
      'rate': '5-20% based on provider history',
      'additional': 'Payment processing, premium features',
      'volume': 'High volume, varied margins',
    },
    'Glovo/Uber Eats': {
      'model': 'Commission + delivery fees',
      'rate': '15-30% from restaurants + customer delivery fees',
      'additional': 'Service fees, surge pricing',
      'volume': 'Very high volume, competitive margins',
    },
    'HandyMan Services': {
      'model': 'Marketplace commission',
      'rate': '10-20% of job value',
      'additional': 'Lead generation fees, premium profiles',
      'volume': 'Medium volume, higher job values',
    },
  };

  static String get revenueStrategy => '''
HomeLinkGH Revenue Strategy:

1. SERVICE COMMISSIONS (Primary Revenue)
   - Standard: 15% of job value
   - Range: 10-25% based on service category
   - Minimum: GH₵5 per transaction
   - Maximum: GH₵200 per transaction

2. PAYMENT PROCESSING FEES
   - 2.5% of total transaction
   - Covers mobile money, card processing
   - Passed to customer transparently

3. INSURANCE & PROTECTION
   - 1% insurance fee for job protection
   - Covers damages, disputes, quality issues
   - Builds customer confidence

4. ADDITIONAL REVENUE STREAMS
   - Premium provider profiles: GH₵50/month
   - Featured listings: GH₵20/week
   - Background check fees: GH₵30/provider
   - Verification badges: GH₵15/verification
   - Business analytics: GH₵25/month
   - Priority customer support: GH₵10/month

5. SEASONAL & PROMOTIONAL
   - Holiday surge pricing: +20-50%
   - Emergency service premiums: +100%
   - Peak time adjustments
   - Volume discounts for high-performing providers

6. B2B SERVICES
   - Corporate accounts: Custom rates
   - Bulk booking discounts
   - White-label solutions
   - API access fees

Expected Monthly Revenue (Conservative):
- 1,000 jobs/month × GH₵100 average × 15% = GH₵15,000
- Payment processing: GH₵2,500
- Premium services: GH₵5,000
- Total: GH₵22,500/month (GH₵270,000/year)

Growth projections scale exponentially with user base.
''';
}