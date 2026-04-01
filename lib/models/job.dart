class Job {
  final String id;
  final String title;
  final String description;
  final String serviceType;
  final double budget;
  final double price; // Alias for budget
  final String status;
  final DateTime createdAt;
  final DateTime scheduledDate; // When the job is scheduled
  final String? providerId;
  final String customerId;
  final String customerName;
  final String address;
  final List<String> requirements;
  final String? specialInstructions;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.budget,
    required this.status,
    required this.createdAt,
    required this.scheduledDate,
    this.providerId,
    required this.customerId,
    required this.customerName,
    required this.address,
    this.requirements = const [],
    this.specialInstructions,
  }) : price = budget;

  factory Job.fromMap(Map<String, dynamic> map, String id) {
    return Job(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      serviceType: map['serviceType'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      scheduledDate: DateTime.parse(map['scheduledDate'] ?? DateTime.now().toIso8601String()),
      providerId: map['providerId'],
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Customer',
      address: map['address'] ?? 'Address not provided',
      requirements: List<String>.from(map['requirements'] ?? []),
      specialInstructions: map['specialInstructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'serviceType': serviceType,
      'budget': budget,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'providerId': providerId,
      'customerId': customerId,
      'customerName': customerName,
      'address': address,
      'requirements': requirements,
      'specialInstructions': specialInstructions,
    };
  }
}