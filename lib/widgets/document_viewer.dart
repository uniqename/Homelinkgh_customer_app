import 'package:flutter/material.dart';

class DocumentViewer extends StatelessWidget {
  final String documentType;
  final Map<String, dynamic> documentData;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const DocumentViewer({
    super.key,
    required this.documentType,
    required this.documentData,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('$documentType Verification'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document image/preview
            _buildDocumentPreview(),
            const SizedBox(height: 20),
            
            // Document details
            _buildDocumentDetails(),
            const SizedBox(height: 20),
            
            // Verification checklist
            _buildVerificationChecklist(),
            const SizedBox(height: 20),
            
            // Action buttons
            if (onApprove != null && onReject != null)
              _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: documentData['imageUrl'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                documentData['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDocumentPlaceholder(),
              ),
            )
          : _buildDocumentPlaceholder(),
    );
  }

  Widget _buildDocumentPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getDocumentIcon(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            documentType,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'SAMPLE DOCUMENT',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Document Information',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._getDocumentFields().map((field) => 
            _buildDetailRow(field['label']!, field['value']!),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationChecklist() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Verification Checklist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._getVerificationItems().map((item) => 
            _buildChecklistItem(item['text'], item['isChecked']),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isChecked ? Colors.black : Colors.grey,
                fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onReject?.call();
            },
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onApprove?.call();
            },
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getDocumentIcon() {
    switch (documentType.toLowerCase()) {
      case 'ghana card':
      case 'id card':
        return Icons.badge;
      case 'business license':
        return Icons.business;
      case 'certificate':
      case 'training certificate':
        return Icons.school;
      case 'utility bill':
        return Icons.receipt;
      default:
        return Icons.description;
    }
  }

  List<Map<String, String>> _getDocumentFields() {
    switch (documentType.toLowerCase()) {
      case 'ghana card':
        return [
          {'label': 'Full Name', 'value': documentData['fullName'] ?? 'John Doe Mensah'},
          {'label': 'ID Number', 'value': documentData['idNumber'] ?? 'GHA-123456789-0'},
          {'label': 'Date of Birth', 'value': documentData['dateOfBirth'] ?? '15/03/1990'},
          {'label': 'Date of Issue', 'value': documentData['issueDate'] ?? '10/01/2020'},
          {'label': 'Expiry Date', 'value': documentData['expiryDate'] ?? '10/01/2030'},
          {'label': 'District', 'value': documentData['district'] ?? 'Accra Metropolitan'},
        ];
      case 'business license':
        return [
          {'label': 'Business Name', 'value': documentData['businessName'] ?? 'Sample Business Ltd'},
          {'label': 'License Number', 'value': documentData['licenseNumber'] ?? 'BL-2024-001234'},
          {'label': 'Registration Date', 'value': documentData['registrationDate'] ?? '01/01/2024'},
          {'label': 'Expiry Date', 'value': documentData['expiryDate'] ?? '31/12/2024'},
          {'label': 'Business Type', 'value': documentData['businessType'] ?? 'Service Provider'},
          {'label': 'Registrar', 'value': documentData['registrar'] ?? 'Registrar General'},
        ];
      case 'certificate':
      case 'training certificate':
        return [
          {'label': 'Certificate Name', 'value': documentData['certificateName'] ?? 'Professional Certification'},
          {'label': 'Issued To', 'value': documentData['issuedTo'] ?? 'John Doe'},
          {'label': 'Issuing Authority', 'value': documentData['issuingAuthority'] ?? 'Ghana Training Institute'},
          {'label': 'Issue Date', 'value': documentData['issueDate'] ?? '15/06/2023'},
          {'label': 'Certificate ID', 'value': documentData['certificateId'] ?? 'CERT-2023-5678'},
          {'label': 'Grade/Level', 'value': documentData['grade'] ?? 'Grade A'},
        ];
      default:
        return [
          {'label': 'Document Type', 'value': documentType},
          {'label': 'Status', 'value': 'Pending Verification'},
          {'label': 'Submitted Date', 'value': documentData['submittedDate'] ?? '20/07/2024'},
        ];
    }
  }

  List<Map<String, dynamic>> _getVerificationItems() {
    switch (documentType.toLowerCase()) {
      case 'ghana card':
        return [
          {'text': 'Document is clear and readable', 'isChecked': true},
          {'text': 'Ghana Card format is authentic', 'isChecked': true},
          {'text': 'Personal details are visible', 'isChecked': true},
          {'text': 'ID number format is valid', 'isChecked': true},
          {'text': 'Document is not expired', 'isChecked': true},
          {'text': 'Photo matches applicant (if available)', 'isChecked': false},
        ];
      case 'business license':
        return [
          {'text': 'License document is clear and readable', 'isChecked': true},
          {'text': 'Business name matches application', 'isChecked': true},
          {'text': 'License is currently valid/not expired', 'isChecked': true},
          {'text': 'License number is properly formatted', 'isChecked': true},
          {'text': 'Issuing authority is legitimate', 'isChecked': true},
          {'text': 'Business type matches service category', 'isChecked': false},
        ];
      case 'certificate':
      case 'training certificate':
        return [
          {'text': 'Certificate is clear and readable', 'isChecked': true},
          {'text': 'Name matches other documents', 'isChecked': true},
          {'text': 'Issuing institution is recognized', 'isChecked': true},
          {'text': 'Certificate relates to service offered', 'isChecked': true},
          {'text': 'Certificate appears authentic', 'isChecked': true},
          {'text': 'Grade/performance is adequate', 'isChecked': false},
        ];
      default:
        return [
          {'text': 'Document is clear and readable', 'isChecked': true},
          {'text': 'Document appears authentic', 'isChecked': true},
          {'text': 'Information matches application', 'isChecked': true},
        ];
    }
  }
}