import 'package:flutter/material.dart';
import 'smart_booking_flow.dart';

class JobsCareersScreen extends StatefulWidget {
  const JobsCareersScreen({super.key});

  @override
  State<JobsCareersScreen> createState() => _JobsCareersScreenState();
}

class _JobsCareersScreenState extends State<JobsCareersScreen> {
  final List<Map<String, dynamic>> _jobCategories = [
    {
      'title': 'Food Delivery Driver',
      'description': 'Deliver food across Greater Accra. Own motorbike/car required.',
      'requirements': [
        'Valid Ghana driver\'s license',
        'Own motorbike or car',
        'Smartphone with GPS',
        'Good knowledge of Accra roads'
      ],
      'benefits': [
        'Flexible working hours',
        'GH₵15-25 per delivery',
        'Weekly payments',
        'Fuel allowance'
      ],
      'icon': Icons.delivery_dining,
      'color': Colors.orange,
      'type': 'driver'
    },
    {
      'title': 'House Cleaner',
      'description': 'Professional cleaning services for homes and offices.',
      'requirements': [
        'Experience in professional cleaning',
        'Own cleaning supplies preferred',
        'Reliable and trustworthy',
        'Available weekdays and weekends'
      ],
      'benefits': [
        'GH₵80-150 per job',
        'Choose your schedule',
        'Regular clients',
        'Equipment provided if needed'
      ],
      'icon': Icons.cleaning_services,
      'color': Colors.blue,
      'type': 'cleaner'
    },
    {
      'title': 'Beauty Professional',
      'description': 'Hair styling, makeup, nail tech services at client locations.',
      'requirements': [
        'Certified beauty professional',
        'Portfolio of previous work',
        'Own equipment and supplies',
        'Mobile service capability'
      ],
      'benefits': [
        'GH₵100-300 per appointment',
        'Build your client base',
        'Marketing support',
        'Premium service rates'
      ],
      'icon': Icons.face,
      'color': Colors.pink,
      'type': 'beauty'
    },
    {
      'title': 'Skilled Tradesperson',
      'description': 'Plumbing, electrical, HVAC, carpentry, and home repairs.',
      'requirements': [
        'Professional trade certification',
        'Minimum 2 years experience',
        'Own tools and equipment',
        'Insurance coverage preferred'
      ],
      'benefits': [
        'GH₵200-500 per job',
        'High-value projects',
        'Repeat customers',
        'Professional recognition'
      ],
      'icon': Icons.handyman,
      'color': Colors.brown,
      'type': 'tradesperson'
    },
    {
      'title': 'Transportation Driver',
      'description': 'Airport transfers, city rides, and shopping assistance.',
      'requirements': [
        'Professional driver\'s license',
        'Clean driving record',
        'Well-maintained vehicle',
        'Customer service skills'
      ],
      'benefits': [
        'GH₵50-200 per trip',
        'Airport premium rates',
        'Regular passengers',
        'GPS navigation support'
      ],
      'icon': Icons.directions_car,
      'color': Colors.green,
      'type': 'driver'
    },
    {
      'title': 'Childcare Provider',
      'description': 'Trusted babysitting and childcare services.',
      'requirements': [
        'Background check required',
        'Experience with children',
        'First aid certification preferred',
        'References from previous families'
      ],
      'benefits': [
        'GH₵20-40 per hour',
        'Trusted family connections',
        'Regular schedules available',
        'Safety training provided'
      ],
      'icon': Icons.child_care,
      'color': Colors.purple,
      'type': 'childcare'
    },
  ];

  final List<Map<String, dynamic>> _companyJobs = [
    {
      'title': 'HomeLinkGH Customer Service Representative',
      'department': 'Customer Support',
      'location': 'Accra Office',
      'type': 'Full-time',
      'description': 'Handle customer inquiries, resolve issues, and ensure excellent service quality.',
      'requirements': [
        'Excellent English and local language skills',
        'Customer service experience',
        'Problem-solving skills',
        'Computer literacy'
      ],
      'salary': 'GH₵1,500 - GH₵2,500/month',
      'icon': Icons.headset_mic,
      'color': Colors.indigo,
    },
    {
      'title': 'Operations Coordinator',
      'department': 'Operations',
      'location': 'Greater Accra',
      'type': 'Full-time',
      'description': 'Coordinate service delivery, manage provider relationships, ensure quality standards.',
      'requirements': [
        'Operations or logistics experience',
        'Project management skills',
        'Data analysis capabilities',
        'Leadership experience'
      ],
      'salary': 'GH₵2,500 - GH₵4,000/month',
      'icon': Icons.settings,
      'color': Colors.teal,
    },
    {
      'title': 'Marketing Specialist',
      'department': 'Marketing',
      'location': 'Remote/Accra',
      'type': 'Full-time',
      'description': 'Digital marketing, social media management, community engagement.',
      'requirements': [
        'Digital marketing experience',
        'Social media expertise',
        'Content creation skills',
        'Analytics knowledge'
      ],
      'salary': 'GH₵2,000 - GH₵3,500/month',
      'icon': Icons.campaign,
      'color': Colors.deepOrange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs & Careers'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006B3C), Color(0xFF228B22)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join the HomeLinkGH Team! 🇬🇭',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Help us connect Ghana\'s diaspora with trusted local services. Build your career or start your service business with us.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            const Text(
              'Service Provider Opportunities',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Work independently, set your schedule, build your business',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _jobCategories.length,
              itemBuilder: (context, index) {
                return _buildJobCard(_jobCategories[index], isProvider: true);
              },
            ),
            
            const SizedBox(height: 30),
            const Text(
              'HomeLinkGH Company Positions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006B3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Full-time positions with benefits and growth opportunities',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _companyJobs.length,
              itemBuilder: (context, index) {
                return _buildJobCard(_companyJobs[index], isProvider: false);
              },
            ),
            
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFCD116).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD116)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Color(0xFF006B3C)),
                      SizedBox(width: 8),
                      Text(
                        'Application Process',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. Submit your application through the app\n'
                    '2. Phone screening within 24-48 hours\n'
                    '3. Background verification (for all positions)\n'
                    '4. Skills assessment or trial period\n'
                    '5. Welcome to the HomeLinkGH family!',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
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

  Widget _buildJobCard(Map<String, dynamic> job, {required bool isProvider}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showJobDetails(job, isProvider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: job['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      job['icon'],
                      color: job['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isProvider) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${job['department']} • ${job['location']} • ${job['type']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job['description'],
                style: const TextStyle(fontSize: 14),
              ),
              if (!isProvider && job['salary'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  job['salary'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B3C),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showJobDetails(Map<String, dynamic> job, bool isProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: job['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          job['icon'],
                          color: job['color'],
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['title'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isProvider && job['salary'] != null)
                              Text(
                                job['salary'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF006B3C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    job['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Requirements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...job['requirements'].map<Widget>((req) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(child: Text(req, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  )).toList(),
                  
                  if (isProvider && job['benefits'] != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Benefits & Compensation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...job['benefits'].map<Widget>((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(benefit, style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    )).toList(),
                  ],
                  
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SmartBookingFlowScreen(
                              serviceType: 'Job Application: ${job['title']}',
                              isGuestUser: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}