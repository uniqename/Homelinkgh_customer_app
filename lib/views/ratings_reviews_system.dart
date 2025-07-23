import 'package:flutter/material.dart';
import '../models/provider.dart';

class RatingsReviewsSystem extends StatefulWidget {
  final Provider? provider;

  const RatingsReviewsSystem({super.key, this.provider});

  @override
  State<RatingsReviewsSystem> createState() => _RatingsReviewsSystemState();
}

class _RatingsReviewsSystemState extends State<RatingsReviewsSystem>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Rating overview data
  final double _overallRating = 4.8;
  final int _totalReviews = 156;
  final Map<int, int> _ratingDistribution = {
    5: 98,
    4: 32,
    3: 18,
    2: 6,
    1: 2,
  };

  // Reviews data
  final List<ReviewData> _reviews = [
    ReviewData(
      id: 'review_001',
      customerName: 'Akosua Mensah',
      customerAvatar: 'AM',
      rating: 5.0,
      reviewText: 'Excellent plumbing work! Kwame was very professional, arrived on time, and fixed the kitchen drainage issue quickly. The work area was left clean and tidy. Highly recommend!',
      jobTitle: 'Kitchen Plumbing Repair',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isVerifiedCustomer: true,
      jobAmount: 180.0,
      photos: ['photo1.jpg', 'photo2.jpg'],
      providerResponse: 'Thank you Akosua! It was a pleasure working with you. Please don\'t hesitate to call if you need any plumbing services in the future.',
      respondedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReviewData(
      id: 'review_002',
      customerName: 'Kwame Asante',
      customerAvatar: 'KA',
      rating: 4.0,
      reviewText: 'Good electrical work on the outlet installation. The electrician was knowledgeable and completed the job as expected. Only minor issue was arriving 15 minutes late.',
      jobTitle: 'Electrical Outlet Installation',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isVerifiedCustomer: true,
      jobAmount: 120.0,
      photos: [],
    ),
    ReviewData(
      id: 'review_003',
      customerName: 'Ama Osei',
      customerAvatar: 'AO',
      rating: 5.0,
      reviewText: 'Outstanding cleaning service! The team was thorough, professional, and paid attention to every detail. My house has never looked better. Will definitely book again.',
      jobTitle: 'Deep House Cleaning',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isVerifiedCustomer: true,
      jobAmount: 250.0,
      photos: ['cleaning1.jpg'],
      providerResponse: 'Thank you so much Ama! We\'re delighted you\'re happy with our service. Looking forward to helping you again!',
      respondedAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
    ),
    ReviewData(
      id: 'review_004',
      customerName: 'Samuel Nkrumah',
      customerAvatar: 'SN',
      rating: 3.0,
      reviewText: 'The gardening work was okay but could have been better. Some areas were missed and the cleanup wasn\'t thorough. However, the main lawn work was done well.',
      jobTitle: 'Garden Maintenance',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isVerifiedCustomer: false,
      jobAmount: 200.0,
      photos: [],
      providerResponse: 'Thank you for the feedback Samuel. I apologize for missing those areas. I\'ve noted your concerns and will ensure better thoroughness in future jobs. I\'d be happy to come back and touch up those missed areas at no charge.',
      respondedAt: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
    ),
  ];

  // Performance insights
  final List<PerformanceInsight> _insights = [
    PerformanceInsight(
      category: 'Professionalism',
      score: 4.9,
      trend: TrendDirection.up,
      feedback: 'Customers consistently praise your professional approach',
      icon: Icons.business_center,
      color: Colors.blue,
    ),
    PerformanceInsight(
      category: 'Punctuality',
      score: 4.6,
      trend: TrendDirection.down,
      feedback: 'Some customers mentioned late arrivals. Consider buffer time',
      icon: Icons.schedule,
      color: Colors.orange,
    ),
    PerformanceInsight(
      category: 'Quality',
      score: 4.8,
      trend: TrendDirection.up,
      feedback: 'Work quality is highly rated by customers',
      icon: Icons.star,
      color: Colors.green,
    ),
    PerformanceInsight(
      category: 'Communication',
      score: 4.7,
      trend: TrendDirection.stable,
      feedback: 'Good communication, continue providing updates',
      icon: Icons.message,
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ratings & Reviews',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 20),
                  SizedBox(width: 4),
                  Text('Overview'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review, size: 20),
                  SizedBox(width: 4),
                  Text('Reviews'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 20),
                  SizedBox(width: 4),
                  Text('Insights'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildReviewsTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating summary card
          _buildRatingSummaryCard(),
          const SizedBox(height: 20),
          
          // Rating breakdown
          _buildRatingBreakdown(),
          const SizedBox(height: 20),
          
          // Recent highlights
          _buildRecentHighlights(),
          const SizedBox(height: 20),
          
          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildRatingSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Rating',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _overallRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: List.generate(5, (index) => Icon(
                        Icons.star,
                        color: index < _overallRating.floor()
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        size: 16,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on $_totalReviews reviews',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Excellent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Performance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final starCount = 5 - index;
            final count = _ratingDistribution[starCount] ?? 0;
            final percentage = count / _totalReviews;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '$starCount',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentHighlights() {
    final recentPositiveReviews = _reviews.where((r) => r.rating >= 4.0).take(2).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Highlights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...recentPositiveReviews.map((review) => _buildHighlightItem(review)),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(ReviewData review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.green,
                child: Text(
                  review.customerAvatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          Icons.star,
                          size: 12,
                          color: index < review.rating 
                              ? Colors.amber 
                              : Colors.grey[300],
                        )),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(review.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.reviewText,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Respond to Reviews',
                  Icons.reply,
                  Colors.blue,
                  _respondToReviews,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Request Reviews',
                  Icons.star_border,
                  Colors.orange,
                  _requestReviews,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        // Filter and sort bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Reviews'),
                      selected: true,
                      onSelected: (selected) {},
                      selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Recent'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('5 Stars'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showSortOptions,
                icon: const Icon(Icons.sort),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                ),
              ),
            ],
          ),
        ),

        // Reviews list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(_reviews[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewData review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getRatingColor(review.rating),
                child: Text(
                  review.customerAvatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (review.isVerifiedCustomer) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          Icons.star,
                          size: 16,
                          color: index < review.rating 
                              ? Colors.amber 
                              : Colors.grey[300],
                        )),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(review.createdAt),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GH₵${review.jobAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Job title
          Text(
            review.jobTitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Review text
          Text(
            review.reviewText,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          
          // Photos if any
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ],
          
          // Provider response
          if (review.providerResponse != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.reply,
                        color: Color(0xFF2E7D32),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Your Response',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(review.respondedAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.providerResponse!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _respondToReview(review),
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Respond'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  foregroundColor: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance metrics
          const Text(
            'Performance Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._insights.map((insight) => _buildInsightCard(insight)),
          
          const SizedBox(height: 24),
          
          // Improvement suggestions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Improvement Suggestions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSuggestionItem(
                  'Punctuality',
                  'Consider adding 15-minute buffer time to appointments',
                  Icons.schedule,
                  Colors.orange,
                ),
                _buildSuggestionItem(
                  'Communication',
                  'Send progress updates during longer jobs',
                  Icons.message,
                  Colors.blue,
                ),
                _buildSuggestionItem(
                  'Follow-up',
                  'Contact customers 24 hours after job completion',
                  Icons.follow_the_signs,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(PerformanceInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              insight.icon,
              color: insight.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      insight.category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      insight.score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: insight.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _getTrendIcon(insight.trend),
                      color: _getTrendColor(insight.trend),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  insight.feedback,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.orange;
    return Colors.red;
  }

  IconData _getTrendIcon(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return Colors.green;
      case TrendDirection.down:
        return Colors.red;
      case TrendDirection.stable:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Action methods
  void _respondToReviews() {
    _tabController.animateTo(1);
  }

  void _requestReviews() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Reviews'),
        content: const Text('Send review request to recent customers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review requests sent to recent customers!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _respondToReview(ReviewData review) {
    showDialog(
      context: context,
      builder: (context) {
        String response = '';
        return AlertDialog(
          title: Text('Respond to ${review.customerName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.reviewText,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => response = value,
                decoration: const InputDecoration(
                  hintText: 'Write your response...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
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
                if (response.isNotEmpty) {
                  setState(() {
                    review.providerResponse = response;
                    review.respondedAt = DateTime.now();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response posted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Post Response'),
            ),
          ],
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Most Recent'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Highest Rating'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text('Lowest Rating'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Data models
class ReviewData {
  final String id;
  final String customerName;
  final String customerAvatar;
  final double rating;
  final String reviewText;
  final String jobTitle;
  final DateTime createdAt;
  final bool isVerifiedCustomer;
  final double jobAmount;
  final List<String> photos;
  String? providerResponse;
  DateTime? respondedAt;

  ReviewData({
    required this.id,
    required this.customerName,
    required this.customerAvatar,
    required this.rating,
    required this.reviewText,
    required this.jobTitle,
    required this.createdAt,
    required this.isVerifiedCustomer,
    required this.jobAmount,
    required this.photos,
    this.providerResponse,
    this.respondedAt,
  });
}

class PerformanceInsight {
  final String category;
  final double score;
  final TrendDirection trend;
  final String feedback;
  final IconData icon;
  final Color color;

  PerformanceInsight({
    required this.category,
    required this.score,
    required this.trend,
    required this.feedback,
    required this.icon,
    required this.color,
  });
}

enum TrendDirection {
  up,
  down,
  stable,
}