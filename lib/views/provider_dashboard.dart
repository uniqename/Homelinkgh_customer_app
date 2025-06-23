import 'package:flutter/material.dart';
import 'provider_calendar.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  final List<Map<String, dynamic>> jobRequests = [
    {
      'id': '001',
      'service': 'Plumbing',
      'customer': 'Kwame Asante',
      'location': 'East Legon, Accra',
      'date': '2024-06-22',
      'time': '10:00 AM',
      'description': 'Fix leaky kitchen faucet',
      'price': 'GH₵450',
      'status': 'pending'
    },
    {
      'id': '002',
      'service': 'Electrical',
      'customer': 'Akosua Mensah',
      'location': 'Tema, Greater Accra',
      'date': '2024-06-23',
      'time': '2:00 PM',
      'description': 'Install ceiling fan',
      'price': 'GH₵720',
      'status': 'pending'
    },
    {
      'id': '003',
      'service': 'Cleaning',
      'customer': 'Kofi Boateng',
      'location': 'Kumasi, Ashanti Region',
      'date': '2024-06-21',
      'time': '9:00 AM',
      'description': 'Deep clean 3-bedroom house',
      'price': 'GH₵1200',
      'status': 'accepted'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderCalendar(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Pending', '2', Colors.orange),
                    _buildStatCard('Accepted', '1', Colors.green),
                    _buildStatCard('Completed', '5', Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Job Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: jobRequests.length,
                itemBuilder: (context, index) {
                  final job = jobRequests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${job['service']} - ${job['customer']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job['description']),
                          Text('📍 ${job['location']}'),
                          Text('📅 ${job['date']} at ${job['time']}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            job['price'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: job['status'] == 'pending'
                                  ? Colors.orange
                                  : job['status'] == 'accepted'
                                      ? Colors.green
                                      : Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              job['status'].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _showJobDetails(job);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title),
      ],
    );
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${job['service']} Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${job['customer']}'),
            Text('Location: ${job['location']}'),
            Text('Date: ${job['date']}'),
            Text('Time: ${job['time']}'),
            Text('Description: ${job['description']}'),
            Text('Price: ${job['price']}'),
          ],
        ),
        actions: [
          if (job['status'] == 'pending') ...[
            TextButton(
              onPressed: () {
                setState(() {
                  job['status'] = 'accepted';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job accepted!')),
                );
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job declined')),
                );
              },
              child: const Text('Decline'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}