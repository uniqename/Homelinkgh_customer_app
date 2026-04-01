import 'package:flutter/material.dart';
import '../services/verification_service.dart';

class DynamicProviderProfile extends StatelessWidget {
  final Map<String, dynamic> provider;
  final String serviceType;

  const DynamicProviderProfile({
    super.key,
    required this.provider,
    required this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProviderHeader(),
            const SizedBox(height: 12),
            _buildVerificationBadge(),
            const SizedBox(height: 12),
            _buildServiceSpecificInfo(),
            const SizedBox(height: 12),
            _buildTrustIndicators(),
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getServiceColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            _getServiceIcon(),
            color: _getServiceColor(),
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider['name'] ?? 'Unknown Provider',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(' ${provider['rating'] ?? 0.0} (${provider['reviewCount'] ?? 0} reviews)'),
                ],
              ),
              Text(
                '${provider['experience'] ?? 'New'} • ${provider['location'] ?? 'Location not specified'}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationBadge() {
    final bool isVerified = provider['verified'] ?? false;
    final int trustScore = provider['trustScore'] ?? 0;
    final String verificationType = provider['verificationType'] ?? 'Not verified';

    return VerificationBadge(
      isVerified: isVerified,
      trustScore: trustScore,
      verificationType: verificationType,
    );
  }

  Widget _buildServiceSpecificInfo() {
    switch (serviceType.toLowerCase()) {
      case 'cleaning':
        return _buildCleaningSpecificInfo();
      case 'babysitting':
        return _buildBabysittingSpecificInfo();
      case 'adult sitter':
        return _buildAdultSitterSpecificInfo();
      case 'food delivery':
        return _buildFoodDeliverySpecificInfo();
      case 'grocery':
        return _buildGrocerySpecificInfo();
      case 'laundry':
        return _buildLaundrySpecificInfo();
      case 'nail tech':
        return _buildNailTechSpecificInfo();
      case 'makeup artist':
        return _buildMakeupArtistSpecificInfo();
      default:
        return _buildGeneralServiceInfo();
    }
  }

  Widget _buildCleaningSpecificInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cleaning Services:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: (provider['cleaningTypes'] ?? ['General Cleaning']).map<Widget>((type) {
            return Chip(
              label: Text(type),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
            );
          }).toList(),
        ),
        if (provider['suppliesOwnEquipment'] == true)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('Supplies own equipment', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        if (provider['hourlyRate'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Rate: GH₵${provider['hourlyRate']}/hour',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
      ],
    );
  }

  Widget _buildBabysittingSpecificInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Comprehensive Background Checked', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 4),
              Text('✓ Criminal background check completed'),
              Text('✓ Character references verified'),
              Text('✓ Child safety training certified'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (provider['ageGroups'] != null) ...[
          const Text('Age Groups:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: (provider['ageGroups'] as List).map<Widget>((age) {
              return Chip(
                label: Text(age),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.pink.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
        if (provider['certifications'] != null) ...[
          const SizedBox(height: 8),
          const Text('Certifications:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...((provider['certifications'] as List).map((cert) => 
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.blue, size: 14),
                  const SizedBox(width: 4),
                  Text(cert, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildAdultSitterSpecificInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.health_and_safety, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('Elder Care Specialist', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 4),
              Text('✓ Background verification completed'),
              Text('✓ Medical training certified'),
              Text('✓ Elder care experience verified'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (provider['medicalTraining'] != null) ...[
          const Text('Medical Training:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...((provider['medicalTraining'] as List).map((training) => 
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  const Icon(Icons.medical_services, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(training, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          )),
        ],
        if (provider['specializations'] != null) ...[
          const SizedBox(height: 8),
          const Text('Specializations:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 6,
            children: (provider['specializations'] as List).map<Widget>((spec) {
              return Chip(
                label: Text(spec),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFoodDeliverySpecificInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.timer, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('10-Minute Response Guarantee', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (provider['vehicleType'] != null)
          Row(
            children: [
              const Icon(Icons.motorcycle, size: 16),
              const SizedBox(width: 4),
              Text('Vehicle: ${provider['vehicleType']}'),
            ],
          ),
        if (provider['coverageArea'] != null)
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Text('Coverage: ${provider['coverageArea']}'),
            ],
          ),
        if (provider['avgDeliveryTime'] != null)
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text('Avg. delivery: ${provider['avgDeliveryTime']} mins'),
            ],
          ),
      ],
    );
  }

  Widget _buildGrocerySpecificInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('Personal Shopper', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        if (provider['shopperExperience'] != null)
          Text('Shopping Experience: ${provider['shopperExperience']}'),
        if (provider['specialtyStores'] != null) ...[
          const SizedBox(height: 4),
          const Text('Specialty Stores:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 6,
            children: (provider['specialtyStores'] as List).map<Widget>((store) {
              return Chip(
                label: Text(store),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 4),
        const Text('✓ Quality guarantee on fresh items', style: TextStyle(color: Colors.green, fontSize: 12)),
        const Text('✓ Price comparison and best deals', style: TextStyle(color: Colors.green, fontSize: 12)),
      ],
    );
  }

  Widget _buildLaundrySpecificInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider['laundryServices'] != null) ...[
          const Text('Services:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 6,
            children: (provider['laundryServices'] as List).map<Widget>((service) {
              return Chip(
                label: Text(service),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.teal.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
        if (provider['pickupDays'] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16),
              const SizedBox(width: 4),
              Text('Pickup Days: ${(provider['pickupDays'] as List).join(', ')}'),
            ],
          ),
        ],
        if (provider['turnaroundTime'] != null)
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text('Turnaround: ${provider['turnaroundTime']}'),
            ],
          ),
      ],
    );
  }

  Widget _buildNailTechSpecificInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider['specialties'] != null) ...[
          const Text('Specialties:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 6,
            children: (provider['specialties'] as List).map<Widget>((specialty) {
              return Chip(
                label: Text(specialty),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.pink.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
        if (provider['portfolioCount'] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.photo_library, color: Colors.pink, size: 16),
              const SizedBox(width: 4),
              Text('${provider['portfolioCount']} portfolio pieces'),
            ],
          ),
        ],
        if (provider['socialMediaFollowers'] != null)
          Row(
            children: [
              const Icon(Icons.people, color: Colors.purple, size: 16),
              const SizedBox(width: 4),
              Text('${provider['socialMediaFollowers']} followers'),
            ],
          ),
      ],
    );
  }

  Widget _buildMakeupArtistSpecificInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider['makeupStyles'] != null) ...[
          const Text('Makeup Styles:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 6,
            children: (provider['makeupStyles'] as List).map<Widget>((style) {
              return Chip(
                label: Text(style),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
        if (provider['eventTypes'] != null) ...[
          const SizedBox(height: 8),
          const Text('Event Types:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 6,
            children: (provider['eventTypes'] as List).map<Widget>((event) {
              return Chip(
                label: Text(event),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
        if (provider['brandCertifications'] != null) ...[
          const SizedBox(height: 8),
          const Text('Brand Certifications:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...((provider['brandCertifications'] as List).map((cert) => 
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.purple, size: 14),
                  const SizedBox(width: 4),
                  Text(cert, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildGeneralServiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider['serviceDescription'] != null)
          Text(provider['serviceDescription']),
        if (provider['skills'] != null) ...[
          const SizedBox(height: 8),
          const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 6,
            children: (provider['skills'] as List).map<Widget>((skill) {
              return Chip(
                label: Text(skill),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: _getServiceColor().withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTrustIndicators() {
    return Row(
      children: [
        if (provider['responseTime'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on, color: Colors.green, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${provider['responseTime']} response',
                  style: const TextStyle(fontSize: 10, color: Colors.green),
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        if (provider['completionRate'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.blue, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${provider['completionRate']}% completion',
                  style: const TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _viewFullProfile(context),
            child: const Text('View Profile'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _bookService(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getServiceColor(),
              foregroundColor: Colors.white,
            ),
            child: const Text('Book Now'),
          ),
        ),
      ],
    );
  }

  Color _getServiceColor() {
    switch (serviceType.toLowerCase()) {
      case 'cleaning': return Colors.blue;
      case 'babysitting': return Colors.pink;
      case 'adult sitter': return Colors.orange;
      case 'food delivery': return Colors.red;
      case 'grocery': return Colors.green;
      case 'laundry': return Colors.teal;
      case 'nail tech': return Colors.pink;
      case 'makeup artist': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getServiceIcon() {
    switch (serviceType.toLowerCase()) {
      case 'cleaning': return Icons.cleaning_services;
      case 'babysitting': return Icons.child_care;
      case 'adult sitter': return Icons.elderly;
      case 'food delivery': return Icons.delivery_dining;
      case 'grocery': return Icons.shopping_cart;
      case 'laundry': return Icons.local_laundry_service;
      case 'nail tech': return Icons.colorize;
      case 'makeup artist': return Icons.face;
      default: return Icons.person;
    }
  }

  void _viewFullProfile(BuildContext context) {
    // Navigate to full profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening full profile...')),
    );
  }

  void _bookService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${provider['name']}'),
        content: Text('You are about to book a $serviceType service with ${provider['name']}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking request sent to ${provider['name']}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getServiceColor(),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}