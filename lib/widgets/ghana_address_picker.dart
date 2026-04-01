import 'package:flutter/material.dart';
import '../data/ghana_locations.dart';

class GhanaAddressPicker extends StatefulWidget {
  final Function(Map<String, String>) onAddressSelected;
  final Map<String, String>? initialAddress;
  
  const GhanaAddressPicker({
    super.key,
    required this.onAddressSelected,
    this.initialAddress,
  });

  @override
  State<GhanaAddressPicker> createState() => _GhanaAddressPickerState();
}

class _GhanaAddressPickerState extends State<GhanaAddressPicker> {
  String? selectedRegion;
  String? selectedCity;
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _additionalController = TextEditingController();

  List<String> availableCities = [];
  List<String> filteredCities = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      selectedRegion = widget.initialAddress!['region'];
      selectedCity = widget.initialAddress!['city'];
      _areaController.text = widget.initialAddress!['area'] ?? '';
      _streetController.text = widget.initialAddress!['street'] ?? '';
      _landmarkController.text = widget.initialAddress!['landmark'] ?? '';
      _additionalController.text = widget.initialAddress!['additional'] ?? '';
      
      if (selectedRegion != null) {
        availableCities = GhanaLocations.getCitiesForRegion(selectedRegion!);
        filteredCities = availableCities;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📍 Ghana Address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B3C),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Region Selector
          const Text(
            'Region',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRegion,
                hint: const Text('Select Region'),
                isExpanded: true,
                items: GhanaLocations.getRegionNames().map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRegion = value;
                    selectedCity = null;
                    availableCities = value != null 
                        ? GhanaLocations.getCitiesForRegion(value)
                        : [];
                    filteredCities = availableCities;
                  });
                  _updateAddress();
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // City Selector with Search
          const Text(
            'City/Town',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Search or select city...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        filteredCities = availableCities;
                      } else {
                        filteredCities = availableCities
                            .where((city) => city.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      }
                    });
                  },
                ),
                if (filteredCities.isNotEmpty)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        final isSelected = selectedCity == city;
                        return ListTile(
                          title: Text(
                            city,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF006B3C) : Colors.black,
                            ),
                          ),
                          trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF006B3C)) : null,
                          onTap: () {
                            setState(() {
                              selectedCity = city;
                            });
                            _updateAddress();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Area/Neighborhood
          const Text(
            'Area/Neighborhood',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _areaController,
            decoration: InputDecoration(
              hintText: 'e.g., East Legon, Dansoman, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onChanged: (_) => _updateAddress(),
          ),
          
          const SizedBox(height: 16),
          
          // Street Address
          const Text(
            'Street Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _streetController,
            decoration: InputDecoration(
              hintText: 'House number and street name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onChanged: (_) => _updateAddress(),
          ),
          
          const SizedBox(height: 16),
          
          // Landmark
          const Text(
            'Landmark (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _landmarkController,
            decoration: InputDecoration(
              hintText: 'Near landmark, school, or notable place',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onChanged: (_) => _updateAddress(),
          ),
          
          const SizedBox(height: 16),
          
          // Additional Instructions
          const Text(
            'Additional Instructions (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006B3C),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _additionalController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Gate color, security instructions, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onChanged: (_) => _updateAddress(),
          ),
          
          const SizedBox(height: 24),
          
          // Popular Areas Quick Select
          if (selectedCity != null && _getPopularAreasForCity(selectedCity!).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Popular Areas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006B3C),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getPopularAreasForCity(selectedCity!).map((area) {
                    return GestureDetector(
                      onTap: () {
                        _areaController.text = area;
                        _updateAddress();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF006B3C).withOpacity(0.3)),
                        ),
                        child: Text(
                          area,
                          style: const TextStyle(
                            color: Color(0xFF006B3C),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAddressValid() ? () {
                final address = _buildAddressMap();
                widget.onAddressSelected(address);
                Navigator.pop(context);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getPopularAreasForCity(String city) {
    switch (city.toLowerCase()) {
      case 'accra':
        return ['East Legon', 'Airport Residential', 'Cantonments', 'Labone', 'Osu', 'Ridge'];
      case 'tema':
        return ['Community 1', 'Community 25', 'Sakumono', 'Tema New Town'];
      case 'kumasi':
        return ['Bantama', 'Adum', 'Asokwa', 'Suame'];
      case 'cape coast':
        return ['Pedu', 'Abura', 'University of Cape Coast'];
      default:
        return [];
    }
  }

  bool _isAddressValid() {
    return selectedRegion != null && 
           selectedCity != null && 
           _areaController.text.isNotEmpty && 
           _streetController.text.isNotEmpty;
  }

  Map<String, String> _buildAddressMap() {
    return {
      'region': selectedRegion ?? '',
      'city': selectedCity ?? '',
      'area': _areaController.text,
      'street': _streetController.text,
      'landmark': _landmarkController.text,
      'additional': _additionalController.text,
      'fullAddress': _buildFullAddress(),
    };
  }

  String _buildFullAddress() {
    final parts = <String>[];
    
    if (_streetController.text.isNotEmpty) parts.add(_streetController.text);
    if (_areaController.text.isNotEmpty) parts.add(_areaController.text);
    if (selectedCity != null) parts.add(selectedCity!);
    if (selectedRegion != null) parts.add('${selectedRegion!} Region');
    if (_landmarkController.text.isNotEmpty) parts.add('Near ${_landmarkController.text}');
    
    return parts.join(', ');
  }

  void _updateAddress() {
    if (_isAddressValid()) {
      final address = _buildAddressMap();
      widget.onAddressSelected(address);
    }
  }
}