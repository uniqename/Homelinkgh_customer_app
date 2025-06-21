import 'package:flutter/material.dart';
import 'service_booking.dart';

class DiasporaHomeScreen extends StatefulWidget {
  const DiasporaHomeScreen({super.key});

  @override
  State<DiasporaHomeScreen> createState() => _DiasporaHomeScreenState();
}

class _DiasporaHomeScreenState extends State<DiasporaHomeScreen> {
  int _selectedIndex = 0;
  String selectedLanguage = 'English';
  String arrivalDate = '';
  String ghanaAddress = '';

  final List<String> languages = ['English', 'Akan/Twi', 'Ga', 'Ewe', 'Hausa'];

  final List<Map<String, dynamic>> _serviceBundles = [
    {
      'name': 'Welcome Home Starter',
      'description': 'Deep cleaning + water delivery + grocery stocking',
      'price': '₵450',
      'duration': 'Day 1 Setup',
      'icon': Icons.home,
      'color': const Color(0xFF006B3C),
      'services': ['Deep house cleaning', 'Fresh water delivery (5 gallons)', 'Grocery stocking (essentials)', 'Fridge organization'],
      'popular': true,
    },
    {
      'name': 'Wedding Ready',
      'description': 'Professional makeup + hair styling + tailoring',
      'price': '₵680',
      'duration': '4-6 hours',
      'icon': Icons.celebration,
      'color': const Color(0xFFCE1126),
      'services': ['Professional makeup', 'Hair styling', 'Traditional attire fitting', 'Photo-ready finishing'],
    },
    {
      'name': 'Family Care Weekly',
      'description': 'Elderly care + house cleaning + grocery runs',
      'price': '₵320/week',
      'duration': 'Weekly',
      'icon': Icons.family_restroom,
      'color': const Color(0xFF1E88E5),
      'services': ['Elderly companionship', 'Light house cleaning', 'Grocery shopping', 'Medication reminders'],
    },
    {
      'name': 'Airport VIP',
      'description': 'Airport pickup + house prep + welcome meal',
      'price': '₵380',
      'duration': 'Arrival Day',
      'icon': Icons.flight_land,
      'color': const Color(0xFFF57C00),
      'services': ['Airport pickup (AC vehicle)', 'House preparation', 'Welcome meal prep', 'Local orientation'],
    },
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'name': 'AC Repair', 'icon': Icons.ac_unit, 'color': const Color(0xFF1E88E5), 'urgent': true},
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'color': const Color(0xFF2E7D32), 'urgent': true},
    {'name': 'Generator Service', 'icon': Icons.power, 'color': const Color(0xFFF57C00), 'urgent': true},
    {'name': 'House Cleaning', 'icon': Icons.cleaning_services, 'color': const Color(0xFF6A1B9A)},
    {'name': 'Grocery Shopping', 'icon': Icons.shopping_cart, 'color': const Color(0xFFCE1126)},
    {'name': 'Cooking Service', 'icon': Icons.restaurant, 'color': const Color(0xFF388E3C)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildMyBookingsTab(),
          _buildFamilyTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF006B3C).withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online),
            label: 'My Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.family_restroom),
            label: 'Family',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF006B3C),
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Akwaba Home! 🇬🇭'),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF006B3C), // Ghana Green
                    Color(0xFF228B22),
                    Color(0xFF32CD32),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCD116), // Ghana Gold
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'DIASPORA MODE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3C),
                              ),
                            ),
                          ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: selectedLanguage,
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.language, color: Colors.white),
                            underline: Container(),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            items: languages.map((language) {
                              return DropdownMenuItem(
                                value: language,
                                child: Text(language, style: const TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedLanguage = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Plan your trip, we\'ll prep your house.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('2 service updates waiting')),
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip Planning Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flight_land, color: Color(0xFF1E88E5), size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'I\'m Heading to Ghana',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Arrival Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(const Duration(days: 7)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() {
                                    arrivalDate = '${date.day}/${date.month}/${date.year}';
                                  });
                                }
                              },
                              controller: TextEditingController(text: arrivalDate),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Ghana Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                          hintText: 'Enter your address in Ghana',
                        ),
                        onChanged: (value) {
                          setState(() {
                            ghanaAddress = value;
                          });
                        },
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: arrivalDate.isNotEmpty && ghanaAddress.isNotEmpty 
                              ? () => _showPreBookingOptions() 
                              : null,
                          icon: const Icon(Icons.schedule),
                          label: const Text('Schedule My Services'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Popular Service Bundles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Service Bundles',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _serviceBundles.length,
                    itemBuilder: (context, index) {
                      final bundle = _serviceBundles[index];
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 16),
                        child: _buildServiceBundleCard(bundle),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Quick Services for Immediate Needs
                const Text(
                  'Need Something Urgently?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _quickServices.length,
                  itemBuilder: (context, index) {
                    final service = _quickServices[index];
                    return _buildQuickServiceCard(service);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceBundleCard(Map<String, dynamic> bundle) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showBundleDetails(bundle),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bundle['color'].withValues(alpha: 0.1),
                bundle['color'].withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    bundle['icon'],
                    size: 32,
                    color: bundle['color'],
                  ),
                  const Spacer(),
                  if (bundle['popular'] ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCD116),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'POPULAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3C),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                bundle['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bundle['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bundle['duration'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bundle['price'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: bundle['color'],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _bookBundle(bundle),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bundle['color'],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Book'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickServiceCard(Map<String, dynamic> service) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceBookingScreen(
                serviceName: service['name'],
                serviceIcon: service['icon'],
                serviceColor: service['color'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Icon(
                    service['icon'],
                    size: 32,
                    color: service['color'],
                  ),
                  if (service['urgent'] ?? false)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                service['name'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (service['urgent'] ?? false)
                const Text(
                  '24/7',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyBookingsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_online, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Your Bookings'),
          SizedBox(height: 8),
          Text('Track your scheduled services'),
        ],
      ),
    );
  }

  Widget _buildFamilyTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Family Services'),
          SizedBox(height: 8),
          Text('Book services for your loved ones'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Your Profile'),
          SizedBox(height: 8),
          Text('Manage your account and preferences'),
        ],
      ),
    );
  }

  void _showPreBookingOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Your Arrival Services'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Arriving: $arrivalDate'),
            Text('Address: $ghanaAddress'),
            const SizedBox(height: 16),
            const Text('What would you like us to prepare?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBundleSelection();
            },
            child: const Text('Choose Services'),
          ),
        ],
      ),
    );
  }

  void _showBundleSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommended for Your Arrival'),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: ListView.builder(
            itemCount: _serviceBundles.length,
            itemBuilder: (context, index) {
              final bundle = _serviceBundles[index];
              return ListTile(
                leading: Icon(bundle['icon'], color: bundle['color']),
                title: Text(bundle['name']),
                subtitle: Text(bundle['price']),
                onTap: () {
                  Navigator.pop(context);
                  _bookBundle(bundle);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBundleDetails(Map<String, dynamic> bundle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bundle['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bundle['description']),
            const SizedBox(height: 16),
            const Text('Includes:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...bundle['services'].map<Widget>((service) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• $service'),
            )).toList(),
            const SizedBox(height: 16),
            Text('Price: ${bundle['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Duration: ${bundle['duration']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bookBundle(bundle);
            },
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  void _bookBundle(Map<String, dynamic> bundle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${bundle['name']} for $arrivalDate'),
        backgroundColor: const Color(0xFF006B3C),
        action: SnackBarAction(
          label: 'View Details',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}