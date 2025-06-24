import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'provider.dart';

enum ServiceStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

enum ServicePriority {
  low,
  normal,
  high,
  urgent,
}

class ServiceRequest {
  final String id;
  final String customerId;
  final String serviceType;
  final String description;
  final LatLng customerLocation;
  final String customerAddress;
  final DateTime requestedDateTime;
  final ServicePriority priority;
  final bool isUrgent;
  final Map<String, dynamic>? additionalDetails;
  final double? estimatedPrice;
  final ServiceStatus status;
  final String? providerId;
  final DateTime? scheduledTime;

  ServiceRequest({
    required this.id,
    required this.customerId,
    required this.serviceType,
    required this.description,
    required this.customerLocation,
    required this.customerAddress,
    required this.requestedDateTime,
    this.priority = ServicePriority.normal,
    this.isUrgent = false,
    this.additionalDetails,
    this.estimatedPrice,
    this.status = ServiceStatus.pending,
    this.providerId,
    this.scheduledTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'serviceType': serviceType,
      'description': description,
      'customerLocation': {
        'latitude': customerLocation.latitude,
        'longitude': customerLocation.longitude,
      },
      'customerAddress': customerAddress,
      'requestedDateTime': requestedDateTime.toIso8601String(),
      'priority': priority.toString(),
      'isUrgent': isUrgent,
      'additionalDetails': additionalDetails,
      'estimatedPrice': estimatedPrice,
      'status': status.toString(),
      'providerId': providerId,
      'scheduledTime': scheduledTime?.toIso8601String(),
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      customerId: json['customerId'],
      serviceType: json['serviceType'],
      description: json['description'],
      customerLocation: LatLng(
        json['customerLocation']['latitude'].toDouble(),
        json['customerLocation']['longitude'].toDouble(),
      ),
      customerAddress: json['customerAddress'],
      requestedDateTime: DateTime.parse(json['requestedDateTime']),
      priority: ServicePriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => ServicePriority.normal,
      ),
      isUrgent: json['isUrgent'] ?? false,
      additionalDetails: json['additionalDetails'],
      estimatedPrice: json['estimatedPrice']?.toDouble(),
      status: ServiceStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ServiceStatus.pending,
      ),
      providerId: json['providerId'],
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime'])
          : null,
    );
  }

  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? serviceType,
    String? description,
    LatLng? customerLocation,
    String? customerAddress,
    DateTime? requestedDateTime,
    ServicePriority? priority,
    bool? isUrgent,
    Map<String, dynamic>? additionalDetails,
    double? estimatedPrice,
    ServiceStatus? status,
    String? providerId,
    DateTime? scheduledTime,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      customerLocation: customerLocation ?? this.customerLocation,
      customerAddress: customerAddress ?? this.customerAddress,
      requestedDateTime: requestedDateTime ?? this.requestedDateTime,
      priority: priority ?? this.priority,
      isUrgent: isUrgent ?? this.isUrgent,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      status: status ?? this.status,
      providerId: providerId ?? this.providerId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
}