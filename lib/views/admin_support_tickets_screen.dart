import 'package:flutter/material.dart';

class AdminSupportTicketsScreen extends StatefulWidget {
  const AdminSupportTicketsScreen({super.key});

  @override
  State<AdminSupportTicketsScreen> createState() => _AdminSupportTicketsScreenState();
}

class _AdminSupportTicketsScreenState extends State<AdminSupportTicketsScreen> {
  final List<Map<String, dynamic>> _supportTickets = [
    {
      'id': 'T001',
      'title': 'Payment not processed',
      'description': 'My payment was deducted but the booking is not confirmed. Need urgent help.',
      'user': 'Akosua Mensah',
      'userType': 'Customer',
      'category': 'Payment Issue',
      'priority': 'High',
      'status': 'Open',
      'createdAt': '2024-07-22 09:30',
      'lastUpdate': '2024-07-22 09:30',
      'assignedTo': null,
    },
    {
      'id': 'T002',
      'title': 'Provider not showing up',
      'description': 'The cleaner was supposed to come at 2 PM but never showed up. I need a refund or reschedule.',
      'user': 'Michael Asante',
      'userType': 'Customer',
      'category': 'Service Issue',
      'priority': 'High',
      'status': 'In Progress',
      'createdAt': '2024-07-22 08:15',
      'lastUpdate': '2024-07-22 10:45',
      'assignedTo': 'Admin Team',
    },
    {
      'id': 'T003',
      'title': 'Unable to update profile',
      'description': 'Getting error message when trying to update my business profile. Cannot change service areas.',
      'user': 'Kwame Asante',
      'userType': 'Provider',
      'category': 'Technical Issue',
      'priority': 'Medium',
      'status': 'Open',
      'createdAt': '2024-07-21 16:20',
      'lastUpdate': '2024-07-21 16:20',
      'assignedTo': null,
    },
    {
      'id': 'T004',
      'title': 'App crashing on iOS',
      'description': 'The app keeps crashing when I try to accept a job. iPhone 14 Pro, iOS 17.5.',
      'user': 'Grace Owusu',
      'userType': 'Provider',
      'category': 'Technical Issue',
      'priority': 'Medium',
      'status': 'Resolved',
      'createdAt': '2024-07-20 14:30',
      'lastUpdate': '2024-07-22 11:00',
      'assignedTo': 'Tech Team',
    },
    {
      'id': 'T005',
      'title': 'Verification documents rejected',
      'description': 'My Ghana Card was rejected during verification. The image is clear and valid. Please review.',
      'user': 'Joseph Nkrumah',
      'userType': 'Customer',
      'category': 'Account Issue',
      'priority': 'Low',
      'status': 'Open',
      'createdAt': '2024-07-21 11:45',
      'lastUpdate': '2024-07-21 11:45',
      'assignedTo': null,
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Open', 'In Progress', 'Resolved'];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTickets = _selectedFilter == 'All' 
        ? _supportTickets 
        : _supportTickets.where((ticket) => ticket['status'] == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions.map((filter) => 
              PopupMenuItem(
                value: filter,
                child: Text(filter),
              ),
            ).toList(),
            child: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh tickets
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tickets refreshed')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: const Color(0xFF006B3C),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Tickets list
          Expanded(
            child: filteredTickets.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${_selectedFilter.toLowerCase()} tickets',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const Text(
                        'All tickets have been handled',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = filteredTickets[index];
                    return _buildTicketCard(ticket);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewTicketDetails(ticket),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ID, status, and priority
              Row(
                children: [
                  Text(
                    ticket['id'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(ticket['priority']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket['priority'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                ticket['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Description preview
              Text(
                ticket['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // User info and category
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: _getUserTypeColor(ticket['userType']),
                    child: Text(
                      ticket['user'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ticket['user'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${ticket['userType']})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      ticket['category'],
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    side: const BorderSide(color: Colors.blue, width: 0.5),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Time and assignment info
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Created: ${ticket['createdAt']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (ticket['assignedTo'] != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Assigned to: ${ticket['assignedTo']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'Provider':
        return Colors.green;
      case 'Customer':
        return const Color(0xFF006B3C);
      default:
        return Colors.grey;
    }
  }

  void _viewTicketDetails(Map<String, dynamic> ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TicketDetailsScreen(ticket: ticket),
      ),
    );
  }
}

class _TicketDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;
  
  const _TicketDetailsScreen({required this.ticket});

  @override
  State<_TicketDetailsScreen> createState() => __TicketDetailsScreenState();
}

class __TicketDetailsScreenState extends State<_TicketDetailsScreen> {
  late Map<String, dynamic> ticket;
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ticket = widget.ticket;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket ${ticket['id']}'),
        backgroundColor: const Color(0xFF006B3C),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _updateTicketStatus(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Open',
                child: Text('Mark as Open'),
              ),
              const PopupMenuItem(
                value: 'In Progress',
                child: Text('Mark as In Progress'),
              ),
              const PopupMenuItem(
                value: 'Resolved',
                child: Text('Mark as Resolved'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Priority
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ticket['status']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ticket['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(ticket['priority']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${ticket['priority']} Priority',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    ticket['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getUserTypeColor(ticket['userType']),
                                child: Text(
                                  ticket['user'][0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket['user'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    ticket['userType'],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket['description'],
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Ticket details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ticket Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Category', ticket['category']),
                          _buildDetailRow('Created', ticket['createdAt']),
                          _buildDetailRow('Last Update', ticket['lastUpdate']),
                          _buildDetailRow('Assigned To', ticket['assignedTo'] ?? 'Unassigned'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Response input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _responseController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Response to user',
                    border: OutlineInputBorder(),
                    hintText: 'Type your response here...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sendResponse,
                        icon: const Icon(Icons.send),
                        label: const Text('Send Response'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006B3C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _assignTicket(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      child: const Text('Assign'),
                    ),
                  ],
                ),
              ],
            ),
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
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'Provider':
        return Colors.green;
      case 'Customer':
        return const Color(0xFF006B3C);
      default:
        return Colors.grey;
    }
  }

  void _updateTicketStatus(String newStatus) {
    setState(() {
      ticket['status'] = newStatus;
      ticket['lastUpdate'] = DateTime.now().toString().substring(0, 16);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ticket status updated to $newStatus'),
        backgroundColor: _getStatusColor(newStatus),
      ),
    );
  }

  void _sendResponse() {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a response'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Here you would send the response to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response sent to user'),
        backgroundColor: Colors.green,
      ),
    );
    
    _responseController.clear();
    
    setState(() {
      ticket['lastUpdate'] = DateTime.now().toString().substring(0, 16);
      if (ticket['status'] == 'Open') {
        ticket['status'] = 'In Progress';
      }
    });
  }

  void _assignTicket() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tech Team'),
              leading: Radio<String>(
                value: 'Tech Team',
                groupValue: ticket['assignedTo'],
                onChanged: (value) {
                  setState(() {
                    ticket['assignedTo'] = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Support Team'),
              leading: Radio<String>(
                value: 'Support Team',
                groupValue: ticket['assignedTo'],
                onChanged: (value) {
                  setState(() {
                    ticket['assignedTo'] = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Admin Team'),
              leading: Radio<String>(
                value: 'Admin Team',
                groupValue: ticket['assignedTo'],
                onChanged: (value) {
                  setState(() {
                    ticket['assignedTo'] = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
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
}