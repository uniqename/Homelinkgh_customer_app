import 'package:flutter/material.dart';

class AdminServiceAreasScreen extends StatefulWidget {
  const AdminServiceAreasScreen({super.key});

  @override
  State<AdminServiceAreasScreen> createState() => _AdminServiceAreasScreenState();
}

class _AdminServiceAreasScreenState extends State<AdminServiceAreasScreen> {
  final List<Map<String, dynamic>> _serviceAreas = [
    {
      'id': '1',
      'name': 'Greater Accra',
      'isActive': true,
      'regions': [
        {'name': 'Accra Central', 'isActive': true, 'serviceRadius': 15},
        {'name': 'East Legon', 'isActive': true, 'serviceRadius': 20},
        {'name': 'Osu', 'isActive': true, 'serviceRadius': 10},
        {'name': 'Tema', 'isActive': true, 'serviceRadius': 25},
        {'name': 'Spintex', 'isActive': true, 'serviceRadius': 15},
        {'name': 'Airport Residential', 'isActive': true, 'serviceRadius': 12},
      ],
      'totalProviders': 45,
      'activeBookings': 23,
    },
    {
      'id': '2',
      'name': 'Ashanti Region',
      'isActive': true,
      'regions': [
        {'name': 'Kumasi Metro', 'isActive': true, 'serviceRadius': 20},
        {'name': 'Manhyia', 'isActive': true, 'serviceRadius': 15},
        {'name': 'Asokwa', 'isActive': true, 'serviceRadius': 18},
        {'name': 'Bantama', 'isActive': false, 'serviceRadius': 12},
      ],
      'totalProviders': 28,
      'activeBookings': 15,
    },
    {
      'id': '3',
      'name': 'Western Region',
      'isActive': false,
      'regions': [
        {'name': 'Takoradi', 'isActive': false, 'serviceRadius': 15},
        {'name': 'Sekondi', 'isActive': false, 'serviceRadius': 12},
      ],
      'totalProviders': 8,
      'activeBookings': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Areas'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location),
            onPressed: _addNewServiceArea,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _serviceAreas.length,
        itemBuilder: (context, index) {
          final area = _serviceAreas[index];
          return _buildServiceAreaCard(area, index);
        },
      ),
    );
  }

  Widget _buildServiceAreaCard(Map<String, dynamic> area, int index) {
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
                    area['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: area['isActive'] ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    area['isActive'] ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: area['isActive'],
                  activeColor: const Color(0xFF006B3C),
                  onChanged: (value) {
                    setState(() {
                      area['isActive'] = value;
                      // Update all sub-regions when main area is toggled
                      for (var region in area['regions']) {
                        region['isActive'] = value;
                      }
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Providers',
                    area['totalProviders'].toString(),
                    Icons.person,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Active Bookings',
                    area['activeBookings'].toString(),
                    Icons.book_online,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Sub-regions',
                    area['regions'].length.toString(),
                    Icons.location_city,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sub-regions
            const Text(
              'Sub-regions:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            ...((area['regions'] as List<Map<String, dynamic>>).map((region) => 
              _buildRegionTile(region, area, index)
            ).toList()),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _addSubRegion(area, index),
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Add Sub-region'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _editServiceArea(area, index),
                  icon: const Icon(Icons.edit_location),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3C),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRegionTile(Map<String, dynamic> region, Map<String, dynamic> area, int areaIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          region['isActive'] ? Icons.location_on : Icons.location_off,
          color: region['isActive'] ? Colors.green : Colors.red,
        ),
        title: Text(region['name']),
        subtitle: Text('Service radius: ${region['serviceRadius']} km'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: region['isActive'],
              activeColor: const Color(0xFF006B3C),
              onChanged: area['isActive'] ? (value) {
                setState(() {
                  region['isActive'] = value;
                });
              } : null,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editSubRegion(region, area, areaIndex);
                } else if (value == 'delete') {
                  _deleteSubRegion(region, area, areaIndex);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNewServiceArea() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Service Area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Service Area Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Northern Region',
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
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _serviceAreas.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text.trim(),
                    'isActive': true,
                    'regions': <Map<String, dynamic>>[],
                    'totalProviders': 0,
                    'activeBookings': 0,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Service area added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B3C)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editServiceArea(Map<String, dynamic> area, int index) {
    final nameController = TextEditingController(text: area['name']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Service Area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Service Area Name',
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
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  area['name'] = nameController.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Service area updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B3C)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addSubRegion(Map<String, dynamic> area, int areaIndex) {
    final nameController = TextEditingController();
    final radiusController = TextEditingController(text: '15');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sub-region'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Sub-region Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Adenta',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Service Radius (km)',
                border: OutlineInputBorder(),
                suffixText: 'km',
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
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  (area['regions'] as List<Map<String, dynamic>>).add({
                    'name': nameController.text.trim(),
                    'isActive': area['isActive'],
                    'serviceRadius': int.tryParse(radiusController.text) ?? 15,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sub-region added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B3C)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editSubRegion(Map<String, dynamic> region, Map<String, dynamic> area, int areaIndex) {
    final nameController = TextEditingController(text: region['name']);
    final radiusController = TextEditingController(text: region['serviceRadius'].toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Sub-region'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Sub-region Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Service Radius (km)',
                border: OutlineInputBorder(),
                suffixText: 'km',
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
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  region['name'] = nameController.text.trim();
                  region['serviceRadius'] = int.tryParse(radiusController.text) ?? 15;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sub-region updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B3C)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteSubRegion(Map<String, dynamic> region, Map<String, dynamic> area, int areaIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sub-region'),
        content: Text('Are you sure you want to delete "${region['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                (area['regions'] as List<Map<String, dynamic>>).remove(region);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${region['name']} deleted'),
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