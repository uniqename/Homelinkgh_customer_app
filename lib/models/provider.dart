import 'location.dart';

class Provider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double rating;
  final int totalRatings;
  final int completedJobs;
  final List<String> services;
  final LatLng location;
  final String address;
  final String bio;
  final bool isVerified;
  final bool isActive;
  final String profileImageUrl;
  final List<String> certifications;
  final Map<String, dynamic> availability;

  Provider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rating,
    required this.totalRatings,
    required this.completedJobs,
    required this.services,
    required this.location,
    required this.address,
    required this.bio,
    required this.isVerified,
    required this.isActive,
    required this.profileImageUrl,
    required this.certifications,
    required this.availability,
  });

  factory Provider.fromMap(Map<String, dynamic> map, String id) {
    return Provider(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      completedJobs: map['completedJobs'] ?? 0,
      services: List<String>.from(map['services'] ?? []),
      location: LatLng(
        (map['location']['latitude'] ?? 0.0).toDouble(),
        (map['location']['longitude'] ?? 0.0).toDouble(),
      ),
      address: map['address'] ?? '',
      bio: map['bio'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? false,
      profileImageUrl: map['profileImageUrl'] ?? '',
      certifications: List<String>.from(map['certifications'] ?? []),
      availability: Map<String, dynamic>.from(map['availability'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'rating': rating,
      'totalRatings': totalRatings,
      'completedJobs': completedJobs,
      'services': services,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'address': address,
      'bio': bio,
      'isVerified': isVerified,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
      'certifications': certifications,
      'availability': availability,
    };
  }
}
