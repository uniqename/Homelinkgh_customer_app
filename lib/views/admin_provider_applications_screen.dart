import 'package:flutter/material.dart';
import '../widgets/document_viewer.dart';

class AdminProviderApplicationsScreen extends StatefulWidget {
  const AdminProviderApplicationsScreen({super.key});

  @override
  State<AdminProviderApplicationsScreen> createState() => _AdminProviderApplicationsScreenState();
}

class _AdminProviderApplicationsScreenState extends State<AdminProviderApplicationsScreen> {
  final List<Map<String, dynamic>> _applications = [
    {
      'id': '1',
      'name': 'Samuel Adjei',
      'businessName': 'Adjei Electrical Services',
      'service': 'Electrical Services',
      'location': 'Tema, Greater Accra',
      'phone': '+233 24 567 8901',
      'email': 'samuel.adjei@email.com',
      'submittedDate': '2024-07-20',
      'status': 'pending',
      'experience': '5 years',
      'description': 'Professional electrician with 5 years of experience in residential and commercial electrical work. Specialized in wiring, installations, and repairs.',
      'documents': ['Business License', 'Ghana Card', 'Electrical Certificate'],
      'services': ['Electrical Wiring', 'Appliance Installation', 'Fault Diagnosis', 'Safety Inspections'],
      'workingHours': 'Monday - Saturday: 8:00 AM - 6:00 PM',
      'serviceAreas': ['Tema', 'Ashaiman', 'Devtraco'],
      'portfolio': [
        'Completed 200+ residential installations',
        'Commercial office building rewiring projects',
        'Emergency electrical repairs',
      ],
    },
    {
      'id': '2',
      'name': 'Grace Owusu',
      'businessName': 'Grace Beauty Studio',
      'service': 'Beauty Services',
      'location': 'East Legon, Accra',
      'phone': '+233 26 789 0123',
      'email': 'grace.owusu@email.com',
      'submittedDate': '2024-07-19',
      'status': 'pending',
      'experience': '3 years',
      'description': 'Certified makeup artist and hair stylist specializing in bridal makeup and special events. Trained in both traditional and modern techniques.',
      'documents': ['Business License', 'Ghana Card', 'Beauty Certificate'],
      'services': ['Bridal Makeup', 'Hair Styling', 'Facial Treatments', 'Manicure & Pedicure'],
      'workingHours': 'Tuesday - Sunday: 9:00 AM - 7:00 PM',
      'serviceAreas': ['East Legon', 'Airport Residential', 'Cantonments'],
      'portfolio': [
        'Over 100 bridal makeovers',
        'Celebrity event styling',
        'Traditional Ghanaian styling expertise',
      ],
    },
    {
      'id': '3',
      'name': 'Joseph Nkrumah',
      'businessName': 'Clean Pro Services',
      'service': 'Cleaning Services',
      'location': 'Spintex, Accra',
      'phone': '+233 25 456 7890',
      'email': 'joseph.cleanpro@email.com',
      'submittedDate': '2024-07-18',
      'status': 'pending',
      'experience': '2 years',
      'description': 'Professional cleaning service with focus on residential and office cleaning. Uses eco-friendly products and modern cleaning equipment.',
      'documents': ['Business License', 'Ghana Card'],
      'services': ['House Cleaning', 'Office Cleaning', 'Deep Cleaning', 'Move-in/out Cleaning'],
      'workingHours': 'Monday - Saturday: 7:00 AM - 5:00 PM',
      'serviceAreas': ['Spintex', 'Sakumono', 'Baatsona'],
      'portfolio': [
        'Regular cleaning for 50+ households',
        'Office cleaning contracts',
        'Post-construction cleaning',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Provider Applications'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh data
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Applications refreshed')),
              );
            },
          ),
        ],
      ),
      body: _applications.isEmpty 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_center, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Provider Applications',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'All applications have been processed',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _applications.length,
            itemBuilder: (context, index) {
              final application = _applications[index];
              return _buildApplicationCard(application, index);
            },
          ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with business info
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B3C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      application['businessName'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
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
                      Text(
                        application['businessName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Owner: ${application['name']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            application['location'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pending Review',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Service category and experience
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service Category',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application['service'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Experience',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application['experience'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contact information
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        application['phone'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          application['email'],
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              application['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            // Documents section
            const Text(
              'Submitted Documents:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (application['documents'] as List<String>).map((doc) => 
                GestureDetector(
                  onTap: () => _viewDocument(application, doc),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDocumentIcon(doc),
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          doc,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.visibility,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewFullApplication(application),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectApplication(application, index),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveApplication(application, index),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewFullApplication(Map<String, dynamic> application) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProviderApplicationDetailScreen(application: application),
      ),
    );
  }

  void _viewDocument(Map<String, dynamic> application, String documentType) {
    final documentData = _generateDocumentData(application, documentType);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewer(
          documentType: documentType,
          documentData: documentData,
          onApprove: () => _approveDocument(application, documentType),
          onReject: () => _rejectDocument(application, documentType),
        ),
      ),
    );
  }

  Map<String, dynamic> _generateDocumentData(Map<String, dynamic> application, String documentType) {
    switch (documentType.toLowerCase()) {
      case 'ghana card':
        return {
          'fullName': application['name'],
          'idNumber': 'GHA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          'dateOfBirth': '15/03/1990',
          'issueDate': '10/01/2020',
          'expiryDate': '10/01/2030',
          'district': application['location'].split(',').first,
        };
      case 'business license':
        return {
          'businessName': application['businessName'],
          'licenseNumber': 'BL-2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          'registrationDate': '01/01/2024',
          'expiryDate': '31/12/2024',
          'businessType': application['service'],
          'registrar': 'Registrar General Department',
        };
      case 'electrical certificate':
        return {
          'certificateName': 'Electrical Installation Certificate',
          'issuedTo': application['name'],
          'issuingAuthority': 'Ghana Institution of Engineers',
          'issueDate': '15/06/2023',
          'certificateId': 'EIC-2023-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
          'grade': 'Grade A',
        };
      case 'beauty certificate':
        return {
          'certificateName': 'Professional Beauty & Cosmetology Certificate',
          'issuedTo': application['name'],
          'issuingAuthority': 'Ghana Beauty Academy',
          'issueDate': '20/08/2022',
          'certificateId': 'BC-2022-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
          'grade': 'Distinction',
        };
      default:
        return {
          'documentType': documentType,
          'applicantName': application['name'],
          'submittedDate': application['submittedDate'],
        };
    }
  }

  void _approveDocument(Map<String, dynamic> application, String documentType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$documentType approved for ${application['businessName']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectDocument(Map<String, dynamic> application, String documentType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$documentType rejected for ${application['businessName']}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _approveApplication(Map<String, dynamic> application, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Provider Application'),
        content: Text('Are you sure you want to approve ${application['businessName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _applications.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${application['businessName']} approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rejectApplication(Map<String, dynamic> application, int index) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Provider Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject ${application['businessName']}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection (optional)',
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
              setState(() {
                _applications.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${application['businessName']} application rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Applications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Applications'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Recent Submissions'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('By Service Category'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'ghana card':
        return Icons.badge;
      case 'business license':
        return Icons.business;
      case 'electrical certificate':
      case 'beauty certificate':
        return Icons.school;
      default:
        return Icons.description;
    }
  }
}

class _ProviderApplicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> application;

  const _ProviderApplicationDetailScreen({required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(application['businessName']),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business overview card
            _buildOverviewCard(),
            const SizedBox(height: 16),
            
            // Services offered
            _buildServicesCard(),
            const SizedBox(height: 16),
            
            // Portfolio/Experience
            _buildPortfolioCard(),
            const SizedBox(height: 16),
            
            // Working details
            _buildWorkingDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Business Name', application['businessName']),
          _buildDetailRow('Owner', application['name']),
          _buildDetailRow('Service Category', application['service']),
          _buildDetailRow('Experience', application['experience']),
          _buildDetailRow('Location', application['location']),
          _buildDetailRow('Phone', application['phone']),
          _buildDetailRow('Email', application['email']),
          const SizedBox(height: 12),
          const Text(
            'Description:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            application['description'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Services Offered',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (application['services'] as List<String>).map((service) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF006B3C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF006B3C), width: 1),
                ),
                child: Text(
                  service,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF006B3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Portfolio & Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(application['portfolio'] as List<String>).map((item) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Working Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Working Hours', application['workingHours']),
          const SizedBox(height: 12),
          const Text(
            'Service Areas:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (application['serviceAreas'] as List<String>).map((area) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  area,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}