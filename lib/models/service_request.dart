class ServiceRequest {
  final String id;
  final String serviceType;
  final String description;
  final bool isUrgent;
  final DateTime scheduledDate;
  final double budget;

  ServiceRequest({
    required this.id,
    required this.serviceType,
    required this.description,
    this.isUrgent = false,
    required this.scheduledDate,
    required this.budget,
  });

  factory ServiceRequest.fromMap(Map<String, dynamic> map, String id) {
    return ServiceRequest(
      id: id,
      serviceType: map['serviceType'] ?? '',
      description: map['description'] ?? '',
      isUrgent: map['isUrgent'] ?? false,
      scheduledDate: DateTime.fromMillisecondsSinceEpoch(map['scheduledDate'] ?? 0),
      budget: (map['budget'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceType': serviceType,
      'description': description,
      'isUrgent': isUrgent,
      'scheduledDate': scheduledDate.millisecondsSinceEpoch,
      'budget': budget,
    };
  }
}
