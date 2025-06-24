import 'package:google_maps_flutter/google_maps_flutter.dart';

class Provider {
  final String id;
  final String name;
  final double rating;
  final int completedJobs;
  final List<String> specialties;
  final LatLng location;
  final bool isAvailable;
  final int averageResponseTime; // in minutes
  final String? profileImageUrl;
  final String? phoneNumber;
  final double? hourlyRate;
  final List<String>? certifications;

  Provider({
    required this.id,
    required this.name,
    required this.rating,
    required this.completedJobs,
    required this.specialties,
    required this.location,
    required this.isAvailable,
    required this.averageResponseTime,
    this.profileImageUrl,
    this.phoneNumber,
    this.hourlyRate,
    this.certifications,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'hourlyRate': hourlyRate,
      'certifications': certifications,
    };
  }

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'],
      name: json['name'],
      rating: json['rating'].toDouble(),
      completedJobs: json['completedJobs'],
      specialties: List<String>.from(json['specialties']),
      location: LatLng(
        json['location']['latitude'].toDouble(),
        json['location']['longitude'].toDouble(),
      ),
      isAvailable: json['isAvailable'],
      averageResponseTime: json['averageResponseTime'],
      profileImageUrl: json['profileImageUrl'],
      phoneNumber: json['phoneNumber'],
      hourlyRate: json['hourlyRate']?.toDouble(),
      certifications: json['certifications'] != null 
          ? List<String>.from(json['certifications'])
          : null,
    );
  }

  Provider copyWith({
    String? id,
    String? name,
    double? rating,
    int? completedJobs,
    List<String>? specialties,
    LatLng? location,
    bool? isAvailable,
    int? averageResponseTime,
    String? profileImageUrl,
    String? phoneNumber,
    double? hourlyRate,
    List<String>? certifications,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      specialties: specialties ?? this.specialties,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      certifications: certifications ?? this.certifications,
    );
  }
}

