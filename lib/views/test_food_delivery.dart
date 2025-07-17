import 'package:flutter/material.dart';
import '../services/local_data_service.dart';
import '../models/provider.dart';

class TestFoodDeliveryScreen extends StatefulWidget {
  final bool isGuestUser;
  
  const TestFoodDeliveryScreen({
    super.key,
    this.isGuestUser = false,
  });

  @override
  State<TestFoodDeliveryScreen> createState() => _TestFoodDeliveryScreenState();
}

class _TestFoodDeliveryScreenState extends State<TestFoodDeliveryScreen> {
  final LocalDataService _localData = LocalDataService();
  List<Provider> _foodProviders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodProviders();
  }

  Future<void> _loadFoodProviders() async {
    try {
      print('Loading food providers...');
      final providers = await _localData.getProvidersByService('Food Delivery');
      print('Found ${providers.length} food providers');
      setState(() {
        _foodProviders = providers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading food providers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                      children: [
                        Icon(
                          Icons.delivery_dining,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Food Delivery Working! 🇬🇭',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Navigation is successful!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Found ${_foodProviders.length} Food Delivery Providers',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_foodProviders.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No food delivery providers found. Check the provider data.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _foodProviders.length,
                      itemBuilder: (context, index) {
                        final provider = _foodProviders[index];
                        return _buildProviderCard(provider);
                      },
                    ),
                  
                  const SizedBox(height: 24),
                  const Card(
                    color: Colors.green,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '✅ Navigation Test Successful!\nFood delivery link is working properly.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF006B3C),
          child: Text(
            provider.name[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(provider.name),
        subtitle: Text('Rating: ${provider.rating} • ${provider.completedJobs} jobs'),
        trailing: Text(
          provider.isAvailable ? 'Available' : 'Busy',
          style: TextStyle(
            color: provider.isAvailable ? Colors.green : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected ${provider.name} for food delivery!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}