import 'package:flutter/material.dart';

class AdminServiceConfigurationScreen extends StatefulWidget {
  const AdminServiceConfigurationScreen({super.key});

  @override
  State<AdminServiceConfigurationScreen> createState() => _AdminServiceConfigurationScreenState();
}

class _AdminServiceConfigurationScreenState extends State<AdminServiceConfigurationScreen> {
  final List<Map<String, dynamic>> _services = [
    {
      'id': '1',
      'name': 'House Cleaning',
      'description': 'Professional residential cleaning services',
      'category': 'Cleaning',
      'basePrice': 50.0,
      'isActive': true,
      'requiresVerification': false,
      'estimatedDuration': 120,
      'features': ['Deep cleaning', 'Regular maintenance', 'Kitchen & bathroom'],
    },
    {
      'id': '2',
      'name': 'Plumbing Services',
      'description': 'Professional plumbing repairs and installations',
      'category': 'Technical',
      'basePrice': 80.0,
      'isActive': true,
      'requiresVerification': true,
      'estimatedDuration': 90,
      'features': ['Leak repairs', 'Pipe installation', 'Emergency service'],
    },
    {
      'id': '3',
      'name': 'Beauty Services - Makeup',
      'description': 'Professional makeup and beauty services',
      'category': 'Beauty',
      'basePrice': 100.0,
      'isActive': true,
      'requiresVerification': true,
      'estimatedDuration': 60,
      'features': ['Bridal makeup', 'Special events', 'Photo shoots'],
      'isDynamic': true,
      'dynamicFields': [
        'Event type',
        'Makeup style preference',
        'Duration needed',
        'Number of people',
        'Special requirements',
        'Skin tone/type',
        'Allergies or sensitivities'
      ],
    },
    {
      'id': '4',
      'name': 'Beauty Services - Nail Tech',
      'description': 'Professional nail care and design services',
      'category': 'Beauty',
      'basePrice': 30.0,
      'isActive': true,
      'requiresVerification': true,
      'estimatedDuration': 90,
      'features': ['Manicure', 'Pedicure', 'Nail art', 'Gel polish'],
      'isDynamic': true,
      'dynamicFields': [
        'Service type (manicure/pedicure/both)',
        'Nail design preference',
        'Polish type (regular/gel/acrylic)',
        'Nail length preference',
        'Color preferences',
        'Special occasion',
        'Nail condition/health issues'
      ],
    },
    {
      'id': '5',
      'name': 'Food Delivery',
      'description': 'Restaurant and grocery delivery services',
      'category': 'Food',
      'basePrice': 15.0,
      'isActive': true,
      'requiresVerification': false,
      'estimatedDuration': 45,
      'features': ['Restaurant pickup', 'Grocery shopping', 'Express delivery'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Configuration'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewService,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return _buildServiceCard(service, index);
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    service['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: service['isActive'],
                  activeColor: const Color(0xFF006B3C),
                  onChanged: (value) {
                    setState(() {
                      service['isActive'] = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Category and verification badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(service['category']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service['category'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (service['requiresVerification'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Verification Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (service['isDynamic'] == true)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Dynamic Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              service['description'],
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Service details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Base Price',
                    'GH₵${service['basePrice'].toStringAsFixed(0)}',
                    Icons.monetization_on,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Duration',
                    '${service['estimatedDuration']} min',
                    Icons.access_time,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Features
            if (service['features'] != null) ...[
              const Text(
                'Features:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (service['features'] as List<String>).map((feature) => 
                  Chip(
                    label: Text(
                      feature,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  ),
                ).toList(),
              ),
            ],
            
            // Dynamic fields (for beauty services)
            if (service['isDynamic'] == true && service['dynamicFields'] != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Dynamic Request Fields:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (service['dynamicFields'] as List<String>).map((field) => 
                  Chip(
                    label: Text(
                      field,
                      style: const TextStyle(fontSize: 9),
                    ),
                    backgroundColor: Colors.purple.withValues(alpha: 0.1),
                    side: const BorderSide(color: Colors.purple, width: 0.5),
                  ),
                ).toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewServiceDetails(service),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _editService(service, index),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteService(index),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cleaning':
        return Colors.blue;
      case 'Technical':
        return Colors.orange;
      case 'Beauty':
        return Colors.pink;
      case 'Food':
        return Colors.green;
      case 'Transport':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _addNewService() {
    _showServiceEditor(isNewService: true);
  }

  void _editService(Map<String, dynamic> service, int index) {
    _showServiceEditor(service: service, index: index);
  }

  void _showServiceEditor({Map<String, dynamic>? service, int? index, bool isNewService = false}) {
    final nameController = TextEditingController(text: service?['name'] ?? '');
    final descController = TextEditingController(text: service?['description'] ?? '');
    final priceController = TextEditingController(text: service?['basePrice']?.toString() ?? '');
    final durationController = TextEditingController(text: service?['estimatedDuration']?.toString() ?? '');
    
    String selectedCategory = service?['category'] ?? 'Cleaning';
    bool requiresVerification = service?['requiresVerification'] ?? false;
    bool isDynamic = service?['isDynamic'] ?? false;
    List<String> features = List<String>.from(service?['features'] ?? []);
    List<String> dynamicFields = List<String>.from(service?['dynamicFields'] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isNewService ? 'Add New Service' : 'Edit Service'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Cleaning', 'Technical', 'Beauty', 'Food', 'Transport']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Base Price (GH₵)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duration (min)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Requires Provider Verification'),
                    value: requiresVerification,
                    onChanged: (value) {
                      setDialogState(() {
                        requiresVerification = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Dynamic Request Fields'),
                    subtitle: const Text('Allow customers to specify detailed requirements'),
                    value: isDynamic,
                    onChanged: (value) {
                      setDialogState(() {
                        isDynamic = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newService = {
                  'id': service?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameController.text,
                  'description': descController.text,
                  'category': selectedCategory,
                  'basePrice': double.tryParse(priceController.text) ?? 0.0,
                  'isActive': service?['isActive'] ?? true,
                  'requiresVerification': requiresVerification,
                  'estimatedDuration': int.tryParse(durationController.text) ?? 60,
                  'features': features,
                  if (isDynamic) 'isDynamic': true,
                  if (isDynamic) 'dynamicFields': _getDefaultDynamicFields(selectedCategory, nameController.text),
                };

                setState(() {
                  if (isNewService) {
                    _services.add(newService);
                  } else if (index != null) {
                    _services[index] = newService;
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isNewService ? 'Service added successfully' : 'Service updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B3C)),
              child: Text(isNewService ? 'Add' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getDefaultDynamicFields(String category, String serviceName) {
    if (serviceName.toLowerCase().contains('makeup')) {
      return [
        'Event type',
        'Makeup style preference', 
        'Duration needed',
        'Number of people',
        'Special requirements',
        'Skin tone/type',
        'Allergies or sensitivities'
      ];
    } else if (serviceName.toLowerCase().contains('nail')) {
      return [
        'Service type (manicure/pedicure/both)',
        'Nail design preference',
        'Polish type (regular/gel/acrylic)',
        'Nail length preference', 
        'Color preferences',
        'Special occasion',
        'Nail condition/health issues'
      ];
    }
    
    return [
      'Special requirements',
      'Preferred time',
      'Additional notes',
    ];
  }

  void _viewServiceDetails(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Category: ${service['category']}'),
              Text('Description: ${service['description']}'),
              Text('Base Price: GH₵${service['basePrice']}'),
              Text('Duration: ${service['estimatedDuration']} minutes'),
              Text('Status: ${service['isActive'] ? 'Active' : 'Inactive'}'),
              Text('Verification Required: ${service['requiresVerification'] ? 'Yes' : 'No'}'),
              if (service['isDynamic'] == true)
                const Text('Dynamic Request: Yes'),
              if (service['features'] != null) ...[
                const SizedBox(height: 8),
                const Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...((service['features'] as List<String>).map((f) => Text('• $f'))),
              ],
              if (service['dynamicFields'] != null) ...[
                const SizedBox(height: 8),
                const Text('Dynamic Fields:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...((service['dynamicFields'] as List<String>).map((f) => Text('• $f'))),
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

  void _deleteService(int index) {
    final serviceName = _services[index]['name'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "$serviceName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _services.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$serviceName deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}