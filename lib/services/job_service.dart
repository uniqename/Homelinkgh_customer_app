import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class JobService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Get all available jobs
  static Future<List<Map<String, dynamic>>> getAvailableJobs() async {
    try {
      final querySnapshot = await _db
          .collection('job_postings')
          .where('status', isEqualTo: 'active')
          .orderBy('postedAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return _getDefaultJobs(); // Return predefined jobs if Firestore fails
    }
  }
  
  // Get user's job applications
  static Future<List<Map<String, dynamic>>> getMyApplications(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('job_applications')
          .where('applicantId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return []; // Return empty list if no applications or error
    }
  }
  
  // Submit job application
  static Future<Map<String, dynamic>> submitApplication({
    required String jobId,
    required String applicantName,
    required String applicantEmail,
    required String applicantPhone,
    required String coverLetter,
  }) async {
    try {
      final applicationId = _db.collection('job_applications').doc().id;
      
      await _db.collection('job_applications').doc(applicationId).set({
        'applicationId': applicationId,
        'jobId': jobId,
        'applicantId': 'current_user_id', // Get from auth
        'applicantName': applicantName,
        'applicantEmail': applicantEmail,
        'applicantPhone': applicantPhone,
        'coverLetter': coverLetter,
        'status': 'Applied',
        'appliedAt': FieldValue.serverTimestamp(),
        'appliedDate': DateTime.now().toString().substring(0, 10),
        'lastUpdated': FieldValue.serverTimestamp(),
        'documents': [], // Will be populated when documents are uploaded
        'interviewScheduled': false,
        'feedback': null,
      });
      
      // Send confirmation email/notification
      await NotificationService.sendEmail(
        email: applicantEmail,
        subject: 'Application Received - HomeLinkGH',
        body: '''
Dear $applicantName,

Thank you for your interest in joining the HomeLinkGH team!

We have successfully received your application and will review it carefully. Our recruitment team will be in touch within 3-5 business days.

Application Details:
- Application ID: $applicationId
- Position: [Job Title]
- Submitted: ${DateTime.now().toString().substring(0, 19)}

Next Steps:
1. Application review by our HR team
2. Initial screening call (if selected)
3. Interview process
4. Final decision

If you have any questions, please contact our HR team at careers@homelink.gh

Best regards,
HomeLinkGH Recruitment Team
        ''',
        userId: 'current_user_id',
      );
      
      return {
        'success': true,
        'applicationId': applicationId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Update application status (admin function)
  static Future<void> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
    String? feedback,
    String? interviewDate,
    String? interviewTime,
  }) async {
    final updateData = {
      'status': newStatus,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    
    if (feedback != null) {
      updateData['feedback'] = feedback;
    }
    
    if (interviewDate != null && interviewTime != null) {
      updateData['interviewScheduled'] = true;
      updateData['interviewDate'] = interviewDate;
      updateData['interviewTime'] = interviewTime;
    }
    
    await _db.collection('job_applications').doc(applicationId).update(updateData);
    
    // Send notification to applicant
    final applicationDoc = await _db.collection('job_applications').doc(applicationId).get();
    final applicationData = applicationDoc.data()!;
    
    await NotificationService.sendEmail(
      email: applicationData['applicantEmail'],
      subject: 'Application Update - HomeLinkGH',
      body: 'Your application status has been updated to: $newStatus',
      userId: applicationData['applicantId'],
    );
  }
  
  // Create new job posting (admin function)
  static Future<String> createJobPosting({
    required String title,
    required String department,
    required String location,
    required String schedule,
    required String type,
    required String salaryRange,
    required String summary,
    required String responsibilities,
    required String requirements,
    required String benefits,
    required String applicationProcess,
  }) async {
    final jobId = _db.collection('job_postings').doc().id;
    
    await _db.collection('job_postings').doc(jobId).set({
      'id': jobId,
      'title': title,
      'department': department,
      'location': location,
      'schedule': schedule,
      'type': type,
      'salaryRange': salaryRange,
      'summary': summary,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'benefits': benefits,
      'applicationProcess': applicationProcess,
      'status': 'active',
      'postedAt': FieldValue.serverTimestamp(),
      'postedDays': 0,
      'applications': 0,
      'createdBy': 'hr_admin', // Get from auth
    });
    
    return jobId;
  }
  
  // Get predefined jobs for initial setup
  static List<Map<String, dynamic>> _getDefaultJobs() {
    return [
      {
        'id': 'job_001',
        'title': 'Customer Support Representative',
        'department': 'Customer Experience',
        'location': 'Accra, Ghana (Remote options available)',
        'schedule': 'Full-time',
        'type': 'Full-time',
        'salaryRange': '3,000 - 5,000',
        'postedDays': 2,
        'summary': 'Join our customer support team to help diaspora customers navigate our platform and resolve their service needs with empathy and efficiency.',
        'responsibilities': '''
• Respond to customer inquiries via phone, email, and live chat
• Assist diaspora customers with booking services for their families in Ghana
• Troubleshoot technical issues and guide users through the platform
• Document customer feedback and identify areas for improvement
• Collaborate with providers to resolve service-related issues
• Maintain high customer satisfaction scores
• Process refunds and handle billing inquiries
• Escalate complex issues to appropriate departments
        ''',
        'requirements': '''
• Bachelor's degree or equivalent experience
• Excellent English communication skills (spoken and written)
• Experience in customer service or support roles
• Familiarity with diaspora communities and cultural sensitivity
• Basic computer skills and ability to learn new software
• Problem-solving mindset with attention to detail
• Ability to work flexible hours to support different time zones
• Patience and empathy when dealing with customer concerns
        ''',
        'benefits': '''
• Competitive salary: ₵3,000 - ₵5,000 per month
• Health insurance coverage
• Performance-based bonuses
• Professional development opportunities
• Flexible work arrangements (remote/hybrid options)
• Annual leave and sick days
• Team building activities and company events
• Career advancement opportunities within growing company
        ''',
        'applicationProcess': '''
1. Submit your application with CV and cover letter
2. Initial phone screening (15-20 minutes)
3. Customer service scenario assessment
4. Final interview with team lead
5. Reference check
6. Job offer and onboarding

Typical timeline: 2-3 weeks from application to decision.
        ''',
      },
      
      {
        'id': 'job_002',
        'title': 'Provider Onboarding & Verification Officer',
        'department': 'Operations',
        'location': 'Accra, Ghana',
        'schedule': 'Full-time',
        'type': 'Full-time',
        'salaryRange': '4,000 - 6,500',
        'postedDays': 5,
        'summary': 'Ensure quality and safety by managing the comprehensive onboarding and verification process for all service providers on our platform.',
        'responsibilities': '''
• Conduct thorough background checks on potential service providers
• Verify professional licenses, certifications, and qualifications
• Coordinate in-person interviews and skill assessments
• Maintain detailed records of verification processes
• Develop and update onboarding procedures and requirements
• Train new providers on platform usage and service standards
• Monitor provider performance and conduct periodic re-verifications
• Investigate complaints and take appropriate actions
• Collaborate with legal team on compliance matters
        ''',
        'requirements': '''
• Bachelor's degree in HR, Business Administration, or related field
• 2+ years experience in recruitment, verification, or compliance
• Strong attention to detail and investigative skills
• Knowledge of Ghana's professional licensing requirements
• Excellent interviewing and assessment abilities
• Understanding of background check processes
• Ability to make sound judgments about provider suitability
• Proficiency in database management and record keeping
• Valid driver's license for field visits
        ''',
        'benefits': '''
• Competitive salary: ₵4,000 - ₵6,500 per month
• Health insurance and medical coverage
• Transportation allowance for field work
• Performance bonuses based on provider quality metrics
• Professional development and training opportunities
• Flexible work schedule
• Career growth within operations team
• Company-provided smartphone and laptop
        ''',
        'applicationProcess': '''
1. Application review and CV screening
2. Written assessment on verification procedures
3. Case study presentation on provider evaluation
4. Panel interview with operations team
5. Reference and background check
6. Final approval and job offer

Process duration: 3-4 weeks including thorough background verification.
        ''',
      },
      
      {
        'id': 'job_003',
        'title': 'Mobile App Project Coordinator',
        'department': 'Technology',
        'location': 'Accra, Ghana (Hybrid)',
        'schedule': 'Full-time',
        'type': 'Full-time',
        'salaryRange': '5,500 - 8,000',
        'postedDays': 1,
        'summary': 'Lead the coordination and project management of our mobile application development, ensuring seamless user experience across all platforms.',
        'responsibilities': '''
• Coordinate mobile app development projects from conception to launch
• Work closely with developers, designers, and product managers
• Manage project timelines, budgets, and resource allocation
• Conduct user acceptance testing and quality assurance
• Gather and prioritize feature requests from stakeholders
• Coordinate app store submissions and updates
• Monitor app performance metrics and user feedback
• Facilitate agile development processes and daily standups
• Ensure compliance with mobile platform guidelines
• Document project requirements and technical specifications
        ''',
        'requirements': '''
• Bachelor's degree in IT, Computer Science, or Project Management
• 3+ years experience in mobile app project coordination
• Strong understanding of iOS and Android development processes
• Experience with agile/scrum methodologies
• Proficiency in project management tools (Jira, Trello, Asana)
• Knowledge of app store submission processes
• Excellent communication and coordination skills
• Understanding of UI/UX principles
• Experience with testing methodologies and QA processes
• PMP or similar certification preferred
        ''',
        'benefits': '''
• Competitive salary: ₵5,500 - ₵8,000 per month
• Comprehensive health insurance
• Latest MacBook Pro and mobile devices for testing
• Professional development budget for courses and certifications
• Flexible hybrid work arrangement
• Stock options in the company
• Annual technology allowance
• Conference attendance opportunities
• Team retreats and tech meetups
        ''',
        'applicationProcess': '''
1. Portfolio review and technical assessment
2. Project management scenario evaluation
3. Technical interview with development team
4. Case study presentation on app project coordination
5. Final interview with CTO and product team
6. Reference check and offer negotiation

Timeline: 2-3 weeks with portfolio and case study requirements.
        ''',
      },
      
      {
        'id': 'job_004',
        'title': 'Operations Manager',
        'department': 'Operations',
        'location': 'Accra, Ghana',
        'schedule': 'Full-time',
        'type': 'Full-time',
        'salaryRange': '8,000 - 12,000',
        'postedDays': 3,
        'summary': 'Oversee all operational aspects of HomeLinkGH platform, ensuring efficient service delivery and exceptional customer experience across Ghana.',
        'responsibilities': '''
• Oversee day-to-day operations across all service categories
• Manage provider network and ensure service quality standards
• Monitor and optimize operational KPIs and metrics
• Coordinate between customer support, providers, and management
• Develop and implement operational policies and procedures
• Handle escalated issues and complex problem resolution
• Manage operational budget and resource allocation
• Lead operational team and provide guidance to staff
• Analyze operational data to identify improvement opportunities
• Ensure compliance with regulatory requirements
• Coordinate with regional field supervisors
• Prepare operational reports for executive team
        ''',
        'requirements': '''
• Bachelor's degree in Operations Management, Business, or related field
• 5+ years experience in operations management role
• Strong leadership and team management skills
• Experience in service industry or marketplace operations
• Excellent analytical and problem-solving abilities
• Proficiency in data analysis and reporting tools
• Understanding of quality management systems
• Experience with multi-location or distributed operations
• Strong communication and interpersonal skills
• Ability to work under pressure and meet deadlines
• Knowledge of Ghana's service industry landscape
• MBA or relevant advanced degree preferred
        ''',
        'benefits': '''
• Competitive salary: ₵8,000 - ₵12,000 per month
• Comprehensive health insurance for family
• Company car and fuel allowance
• Performance bonus up to 25% of base salary
• Leadership development programs
• Equity participation in company growth
• Annual leave and executive time off
• Professional conference attendance
• Executive health checkup
• Team building and leadership retreats
        ''',
        'applicationProcess': '''
1. Executive CV review and initial screening
2. Operations case study and presentation
3. Leadership assessment and behavioral interview
4. Panel interview with executive team
5. Reference check with previous employers
6. Final interview with CEO and offer negotiation

Process duration: 4-5 weeks including thorough executive evaluation.
        ''',
      },
      
      {
        'id': 'job_005',
        'title': 'General Manager',
        'department': 'Executive',
        'location': 'Accra, Ghana',
        'schedule': 'Full-time',
        'type': 'Full-time',
        'salaryRange': '15,000 - 25,000',
        'postedDays': 7,
        'summary': 'Lead HomeLinkGH as General Manager with comprehensive oversight of all business operations, strategy execution, and growth initiatives.',
        'responsibilities': '''
• Provide strategic leadership and overall business management
• Oversee all departments: Operations, Technology, Marketing, Finance
• Develop and execute business growth strategies
• Manage relationships with key stakeholders and partners
• Ensure achievement of revenue and profitability targets
• Lead executive team and provide guidance to department heads
• Represent company at industry events and with investors
• Make key business decisions and strategic investments
• Ensure compliance with all legal and regulatory requirements
• Drive innovation and digital transformation initiatives
• Manage crisis situations and business continuity planning
• Report to board of directors and investors
• Build partnerships with diaspora organizations globally
        ''',
        'requirements': '''
• Master's degree in Business Administration, Management, or related field
• 10+ years executive leadership experience
• Proven track record in scaling technology or service businesses
• Experience in emerging markets and diaspora communities
• Strong financial acumen and P&L management experience
• Exceptional leadership and team building skills
• Deep understanding of digital platforms and marketplaces
• International business experience preferred
• Excellent strategic thinking and execution abilities
• Strong network in Ghana's business community
• Fluency in English; local language skills advantageous
• Previous experience with venture-backed companies preferred
        ''',
        'benefits': '''
• Executive salary: ₵15,000 - ₵25,000 per month
• Significant equity stake in company
• Executive health insurance and family coverage
• Company vehicle and driver
• Housing allowance or company accommodation
• Performance bonus up to 40% of base salary
• Annual executive retreat and leadership development
• International travel and conference attendance
• Executive assistant support
• Comprehensive retirement package
• Professional membership fees covered
• Annual vacation allowance
        ''',
        'applicationProcess': '''
1. Executive search and CV evaluation
2. Strategic vision presentation and business plan
3. Multiple rounds of interviews with board members
4. Leadership assessment and 360-degree feedback
5. Reference checks with industry leaders
6. Final board approval and contract negotiation
7. Comprehensive background and financial verification

Timeline: 6-8 weeks including extensive executive evaluation process.
        ''',
      },
      
      {
        'id': 'job_006',
        'title': 'Marketing & Social Media Manager',
        'department': 'Marketing',
        'location': 'Accra, Ghana (Hybrid)',
        'schedule': 'Full-time',
        'type': 'Full-time',
        'salaryRange': '5,000 - 7,500',
        'postedDays': 4,
        'summary': 'Drive brand awareness and user acquisition through strategic marketing campaigns and engaging social media presence targeting Ghana\'s diaspora community.',
        'responsibilities': '''
• Develop and execute comprehensive marketing strategies
• Manage all social media platforms and content creation
• Create engaging content for diaspora audience across multiple channels
• Plan and execute digital marketing campaigns (Google, Facebook, Instagram)
• Coordinate influencer partnerships and community engagement
• Analyze marketing metrics and ROI on campaigns
• Manage marketing budget and vendor relationships
• Coordinate with PR agencies and media partners
• Develop email marketing campaigns and newsletters
• Create marketing materials and brand guidelines
• Organize virtual and in-person marketing events
• Collaborate with product team on feature launches
• Monitor brand reputation and online presence
        ''',
        'requirements': '''
• Bachelor's degree in Marketing, Communications, or related field
• 3+ years experience in digital marketing and social media management
• Strong understanding of diaspora communities and cultural nuances
• Proficiency in marketing tools (Google Analytics, Facebook Ads, Mailchimp)
• Creative content creation skills (graphic design, video editing)
• Experience with influencer marketing and community building
• Excellent writing and communication skills
• Data-driven mindset with analytical skills
• Knowledge of SEO/SEM best practices
• Experience with marketing automation tools
• Understanding of Ghana's digital landscape
• Portfolio of successful marketing campaigns
        ''',
        'benefits': '''
• Competitive salary: ₵5,000 - ₵7,500 per month
• Health insurance coverage
• Marketing tools and software subscriptions
• Professional development budget for courses
• Creative workspace and latest technology
• Performance bonuses based on acquisition metrics
• Flexible work arrangements
• Travel opportunities for campaigns and events
• Team building and creative retreats
• Access to industry conferences and workshops
        ''',
        'applicationProcess': '''
1. Portfolio review and marketing assessment
2. Creative campaign presentation and strategy
3. Social media content creation challenge
4. Interview with marketing team and leadership
5. Reference check and campaign case studies
6. Final interview and salary negotiation

Duration: 2-3 weeks including portfolio evaluation and creative challenges.
        ''',
      },
      
      {
        'id': 'job_007',
        'title': 'Finance & Payments Assistant',
        'department': 'Finance',
        'location': 'Accra, Ghana',
        'schedule': 'Full-time',
        'type': 'Full-time',
        'salaryRange': '3,500 - 5,500',
        'postedDays': 6,
        'summary': 'Support financial operations and payment processing, ensuring accurate transactions and financial reporting for our growing diaspora marketplace.',
        'responsibilities': '''
• Process and reconcile daily payments and transactions
• Monitor payment gateways (Paystack, Flutterwave) and resolve issues
• Assist with accounts receivable and payable management
• Prepare financial reports and payment summaries
• Support provider payout processing and verification
• Handle refund requests and payment disputes
• Maintain accurate financial records and documentation
• Assist with monthly and quarterly financial closing
• Support budget preparation and expense tracking
• Coordinate with banks and payment service providers
• Ensure compliance with financial regulations
• Assist with audit preparation and documentation
• Monitor foreign exchange rates for diaspora transactions
        ''',
        'requirements': '''
• Bachelor's degree in Finance, Accounting, or related field
• 2+ years experience in finance or accounting role
• Understanding of payment processing and fintech
• Proficiency in Excel and accounting software
• Knowledge of Ghana's banking and payment systems
• Attention to detail and accuracy in financial data
• Understanding of foreign exchange and remittances
• Basic knowledge of financial regulations and compliance
• Excellent mathematical and analytical skills
• Ability to work with financial deadlines
• Experience with multi-currency transactions preferred
• Professional accounting certification (ACCA/CIMA) preferred
        ''',
        'benefits': '''
• Competitive salary: ₵3,500 - ₵5,500 per month
• Health insurance coverage
• Professional development for accounting certifications
• Performance bonuses based on accuracy and efficiency
• Flexible work hours
• Annual financial planning training
• Career advancement opportunities in finance team
• Modern office environment with latest technology
• Team lunch and social activities
• Annual professional conference attendance
        ''',
        'applicationProcess': '''
1. CV review and financial assessment test
2. Excel and accounting software proficiency test
3. Payment processing scenario evaluation
4. Interview with finance team and operations manager
5. Reference check with previous employers
6. Background check and offer negotiation

Timeline: 2-3 weeks including assessment tests and background verification.
        ''',
      },
      
      {
        'id': 'job_008',
        'title': 'Field Supervisor',
        'department': 'Operations',
        'location': 'Multiple locations across Ghana',
        'schedule': 'Full-time',
        'type': 'Full-time',
        'salaryRange': '4,500 - 6,500',
        'postedDays': 1,
        'summary': 'Oversee field operations and service delivery across Ghana regions, ensuring quality standards and provider compliance with complete access to all app functionalities.',
        'responsibilities': '''
• Supervise service providers across assigned regions
• Conduct regular quality assessments and site visits
• Use complete app functionality to monitor and manage operations
• Handle escalated service issues and customer complaints
• Ensure provider compliance with safety and quality standards
• Coordinate emergency response and crisis management
• Collect feedback from customers and providers
• Train new providers on service standards and app usage
• Monitor regional performance metrics and KPIs
• Report field observations and recommendations to management
• Coordinate with local authorities and regulatory bodies
• Manage inventory and equipment for field operations
• Document incidents and prepare detailed reports
• Support marketing and expansion initiatives in regions
        ''',
        'requirements': '''
• Bachelor's degree or equivalent field experience
• 3+ years experience in field operations or supervision
• Strong leadership and team management skills
• Excellent problem-solving and decision-making abilities
• Valid driver's license and willingness to travel extensively
• Deep knowledge of Ghana's regions and communities
• Ability to work independently with minimal supervision
• Strong communication skills in English and local languages
• Physical ability to conduct field visits and inspections
• Experience with mobile technology and app usage
• Cultural sensitivity and community engagement skills
• Crisis management and emergency response experience
• Motorcycle or vehicle preferred for rural area access
        ''',
        'benefits': '''
• Competitive salary: ₵4,500 - ₵6,500 per month
• Company vehicle or transportation allowance
• Fuel allowance and travel expenses
• Health insurance and field safety coverage
• Mobile phone and data allowance
• Performance bonuses based on regional metrics
• Professional development and leadership training
• Annual team building and recognition events
• Career advancement to regional management roles
• Safety equipment and protective gear provided
• Annual vacation and personal time off
• Emergency support and 24/7 company assistance
        ''',
        'applicationProcess': '''
1. Application review and regional knowledge assessment
2. Field scenario evaluation and problem-solving test
3. Interview with operations manager and regional team
4. Field visit simulation and practical assessment
5. Reference check with previous supervisors
6. Background and driving record verification
7. Final interview and assignment to region

Process duration: 3-4 weeks including field assessments and background checks.
        ''',
      },
    ];
  }
  
  // Initialize default jobs in Firestore (run once during setup)
  static Future<void> initializeDefaultJobs() async {
    final jobs = _getDefaultJobs();
    
    for (final job in jobs) {
      await _db.collection('job_postings').doc(job['id']).set({
        ...job,
        'status': 'active',
        'postedAt': FieldValue.serverTimestamp(),
        'applications': 0,
        'createdBy': 'system_init',
      });
    }
  }
  
  // Get job statistics for admin dashboard
  static Future<Map<String, dynamic>> getJobStatistics() async {
    try {
      final jobsSnapshot = await _db.collection('job_postings').get();
      final applicationsSnapshot = await _db.collection('job_applications').get();
      
      int totalJobs = jobsSnapshot.size;
      int activeJobs = jobsSnapshot.docs.where((doc) => doc.data()['status'] == 'active').length;
      int totalApplications = applicationsSnapshot.size;
      
      // Calculate applications by status
      Map<String, int> applicationsByStatus = {};
      for (final doc in applicationsSnapshot.docs) {
        final status = doc.data()['status'] as String;
        applicationsByStatus[status] = (applicationsByStatus[status] ?? 0) + 1;
      }
      
      return {
        'totalJobs': totalJobs,
        'activeJobs': activeJobs,
        'totalApplications': totalApplications,
        'applicationsByStatus': applicationsByStatus,
        'averageApplicationsPerJob': totalJobs > 0 ? (totalApplications / totalJobs).round() : 0,
      };
    } catch (e) {
      return {
        'totalJobs': 0,
        'activeJobs': 0,
        'totalApplications': 0,
        'applicationsByStatus': {},
        'averageApplicationsPerJob': 0,
      };
    }
  }
}