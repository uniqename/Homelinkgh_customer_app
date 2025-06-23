import 'package:flutter/material.dart';

class ProviderCalendar extends StatefulWidget {
  const ProviderCalendar({super.key});

  @override
  State<ProviderCalendar> createState() => _ProviderCalendarState();
}

class _ProviderCalendarState extends State<ProviderCalendar> {
  final List<Map<String, dynamic>> appointments = [
    {
      'date': '2024-06-21',
      'time': '9:00 AM',
      'service': 'Deep Cleaning',
      'customer': 'Kofi Boateng',
      'location': 'Kumasi, Ashanti Region',
      'status': 'confirmed'
    },
    {
      'date': '2024-06-22',
      'time': '10:00 AM',
      'service': 'Plumbing',
      'customer': 'Kwame Asante',
      'location': 'East Legon, Accra',
      'status': 'pending'
    },
    {
      'date': '2024-06-23',
      'time': '2:00 PM',
      'service': 'Electrical',
      'customer': 'Akosua Mensah',
      'location': 'Tema, Greater Accra',
      'status': 'pending'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Upcoming Appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appointment['status'] == 'confirmed'
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          appointment['time'].split(' ')[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        '${appointment['service']} - ${appointment['customer']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📍 ${appointment['location']}'),
                          Text('📅 ${appointment['date']} at ${appointment['time']}'),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: appointment['status'] == 'confirmed'
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment['status'].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showAppointmentDetails(appointment);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add availability feature coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${appointment['service']} Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${appointment['customer']}'),
            Text('Location: ${appointment['location']}'),
            Text('Date: ${appointment['date']}'),
            Text('Time: ${appointment['time']}'),
            Text('Status: ${appointment['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact customer feature coming soon!'),
                ),
              );
            },
            child: const Text('Contact Customer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}