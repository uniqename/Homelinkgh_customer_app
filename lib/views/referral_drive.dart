import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferralDriveScreen extends StatefulWidget {
  const ReferralDriveScreen({super.key});

  @override
  State<ReferralDriveScreen> createState() => _ReferralDriveScreenState();
}

class _ReferralDriveScreenState extends State<ReferralDriveScreen> {
  final String userReferralCode = "HOMELINK_GH_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
  int totalReferrals = 5;
  double earnedRewards = 100.0;
  int pendingReferrals = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soft Launch Referrals'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF006B3C),
              Color(0xFF228B22),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soft Launch Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCD116).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.rocket_launch,
                        size: 50,
                        color: Color(0xFF006B3C),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '🚀 Soft Launch Pioneer',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Help us grow Ghana\\'s diaspora community!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF006B3C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Limited Time: Double Rewards!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Referral Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Referrals',
                        totalReferrals.toString(),
                        Icons.people,
                        const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Rewards Earned',
                        '₵${earnedRewards.toStringAsFixed(0)}',
                        Icons.monetization_on,
                        const Color(0xFFF57C00),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        pendingReferrals.toString(),
                        Icons.hourglass_empty,
                        const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Your Referral Code
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Referral Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF006B3C),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userReferralCode,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3C),
                                letterSpacing: 1.2,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: userReferralCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Referral code copied!'),
                                    backgroundColor: Color(0xFF006B3C),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.copy,
                                color: Color(0xFF006B3C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // How It Works
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How Soft Launch Referrals Work',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHowItWorksStep(
                        '1',
                        'Share Your Code',
                        'Send your unique code to family and friends in the diaspora',
                        Icons.share,
                      ),
                      _buildHowItWorksStep(
                        '2',
                        'They Sign Up',
                        'New users join HomeLinkGH using your referral code',
                        Icons.person_add,
                      ),
                      _buildHowItWorksStep(
                        '3',
                        'Both Get Rewards',
                        'You earn ₵40, they get ₵20 credit (doubled during soft launch!)',
                        Icons.card_giftcard,
                      ),
                      _buildHowItWorksStep(
                        '4',
                        'Build Community',
                        'Help grow Ghana\\'s most trusted diaspora service platform',
                        Icons.group,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Share Buttons
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadBox(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share HomeLinkGH',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildShareButton(
                              'WhatsApp',
                              Icons.message,
                              const Color(0xFF25D366),
                              () => _shareToWhatsApp(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildShareButton(
                              'Facebook',
                              Icons.facebook,
                              const Color(0xFF1877F2),
                              () => _shareToFacebook(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildShareButton(
                              'Twitter',
                              Icons.alternate_email,
                              const Color(0xFF1DA1F2),
                              () => _shareToTwitter(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildShareButton(
                              'More',
                              Icons.share,
                              const Color(0xFF757575),
                              () => _shareGeneral(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Leaderboard Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Referral Leaderboard',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006B3C),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to full leaderboard
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLeaderboardItem(1, 'Akosua M.', '🇺🇸', 23),
                      _buildLeaderboardItem(2, 'Kwame A.', '🇬🇧', 18),
                      _buildLeaderboardItem(3, 'Ama D.', '🇨🇦', 15),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCD116).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Rank: #${_getUserRank()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3C),
                              ),
                            ),
                            Text(
                              '$totalReferrals referrals',
                              style: const TextStyle(
                                color: Color(0xFF006B3C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep(String number, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF006B3C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFF006B3C), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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

  Widget _buildShareButton(String platform, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(platform),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String flag, int referrals) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rank == 1 ? const Color(0xFFFCD116) : 
                    rank == 2 ? Colors.grey[300] :
                    rank == 3 ? const Color(0xFFCD7F32) : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$referrals referrals',
            style: const TextStyle(
              color: Color(0xFF006B3C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _getUserRank() {
    // Calculate user rank based on referrals
    final ranks = [23, 18, 15, 12, 8, totalReferrals, 3, 2, 1];
    ranks.sort((a, b) => b.compareTo(a));
    return ranks.indexOf(totalReferrals) + 1;
  }

  void _shareToWhatsApp() {
    final message = "🇬🇭 Join me on HomeLinkGH - Ghana's premier diaspora service platform! Use my code $userReferralCode and get ₵20 credit. Perfect for booking services before you land! Download: https://homelink.gh/app";
    // Implement WhatsApp sharing
  }

  void _shareToFacebook() {
    // Implement Facebook sharing
  }

  void _shareToTwitter() {
    final message = "🇬🇭 Excited to be part of @HomeLinkGH soft launch! Connecting Ghana's diaspora with trusted home services. Use code $userReferralCode for ₵20 credit! #GhanaDiaspora #HomeLinkGH";
    // Implement Twitter sharing
  }

  void _shareGeneral() {
    final message = "Join me on HomeLinkGH - the platform connecting Ghana's diaspora with trusted home services! Use referral code $userReferralCode and get ₵20 credit. Download: https://homelink.gh/app";
    // Implement general sharing
  }
}