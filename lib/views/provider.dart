import 'package:homelinkgh_customer/models/location.dart';

class Provider {
  final String id;
  final String name;
  final double rating;
  final int completedJobs;
  final List<String> services;
  final LatLng location;
  final bool isAvailable;
  final int averageResponseTime;

  Provider({
    required this.id,
    required this.name,
    required this.rating,
    required this.completedJobs,
    required this.services,
    required this.location,
    required this.isAvailable,
    required this.averageResponseTime,
  });

  factory Provider.fromMap(Map<String, dynamic> map, String id) {
    return Provider(
      id: id,
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      services: List<String>.from(map['services'] ?? []),
      location: LatLng(
        (map['location']['latitude'] ?? 0.0).toDouble(),
        (map['location']['longitude'] ?? 0.0).toDouble(),
      ),
      isAvailable: map['isAvailable'] ?? false,
      averageResponseTime: map['averageResponseTime'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'completedJobs': completedJobs,
      'services': services,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'isAvailable': isAvailable,
      'averageResponseTime': averageResponseTime,
    };
  }
}
