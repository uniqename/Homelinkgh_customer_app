import 'package:google_maps_flutter/google_maps_flutter.dart';

class Provider {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final double rating;
  final int completedJobs;
  final List<String> specialties;
  final LatLng location;
  bool isAvailable;
  final int averageResponseTime;
  final String? profileImage;
  final String? description;

  Provider({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.rating,
    required this.completedJobs,
    required this.specialties,
    required this.location,
    required this.isAvailable,
    required this.averageResponseTime,
    this.profileImage,
    this.description,
  });

  factory Provider.fromMap(Map<String, dynamic> map, String id) {
    return Provider(
      id: id,
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      specialties: List<String>.from(map['specialties'] ?? []),
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
      'specialties': specialties,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'isAvailable': isAvailable,
      'averageResponseTime': averageResponseTime,
    };
  }
}
