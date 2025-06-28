import 'package:google_maps_flutter/google_maps_flutter.dart';

class Provider {
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final double rating;
  final int completedJobs;
  final List<String> services; // Changed from specialties to services
  final LatLng location;
  bool isAvailable;
  final int averageResponseTime;
  final String? profileImageUrl; // Changed from profileImage
  final String? bio; // Changed from description
  final double? hourlyRate;
  final String? experience;
  final List<String>? languages;
  final List<String>? certifications;
  final List<String>? portfolioImages;

  Provider({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    required this.rating,
    required this.completedJobs,
    required this.services, // Updated parameter name
    required this.location,
    required this.isAvailable,
    required this.averageResponseTime,
    this.profileImageUrl,
    this.bio,
    this.hourlyRate,
    this.experience,
    this.languages,
    this.certifications,
    this.portfolioImages,
  });

  factory Provider.fromMap(Map<String, dynamic> map, String id) {
    return Provider(
      id: id,
      name: map['name'] ?? '',
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      services: List<String>.from(map['services'] ?? []),
      location: LatLng(
        (map['location']['latitude'] ?? 0.0).toDouble(),
        (map['location']['longitude'] ?? 0.0).toDouble(),
      ),
      isAvailable: map['isAvailable'] ?? false,
      averageResponseTime: map['averageResponseTime'] ?? 0,
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      hourlyRate: map['hourlyRate']?.toDouble(),
      experience: map['experience'],
      languages: map['languages'] != null ? List<String>.from(map['languages']) : null,
      certifications: map['certifications'] != null ? List<String>.from(map['certifications']) : null,
      portfolioImages: map['portfolioImages'] != null ? List<String>.from(map['portfolioImages']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'completedJobs': completedJobs,
      'services': services,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'isAvailable': isAvailable,
      'averageResponseTime': averageResponseTime,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'experience': experience,
      'languages': languages,
      'certifications': certifications,
      'portfolioImages': portfolioImages,
    };
  }
}
