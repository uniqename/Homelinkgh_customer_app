class Job {
  final String id;
  final String title;
  final String description;
  final String serviceType;
  final double budget;
  final String status;
  final DateTime createdAt;
  final String? providerId;
  final String customerId;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.budget,
    required this.status,
    required this.createdAt,
    this.providerId,
    required this.customerId,
  });

  factory Job.fromMap(Map<String, dynamic> map, String id) {
    return Job(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      serviceType: map['serviceType'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      providerId: map['providerId'],
      customerId: map['customerId'] ?? '',
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
      'providerId': providerId,
      'customerId': customerId,
    };
  }
}