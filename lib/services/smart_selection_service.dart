import 'dart:math';
import 'package:homelinkgh_customer/models/location.dart';
import '../models/provider.dart';
import '../models/service_request.dart';
import 'local_data_service.dart';

class SmartSelectionService {
  static final SmartSelectionService _instance = SmartSelectionService._internal();
  factory SmartSelectionService() => _instance;
  SmartSelectionService._internal();

  final LocalDataService _localData = LocalDataService();

  // Get providers from local data service
  Future<List<Provider>> _getProviders() async {
    return await _localData.getAllProviders();
  }

  // Original provider data as fallback
  final List<Provider> _fallbackProviders = [
    Provider(
      id: '1',
      name: 'Kwame Asante',
      email: 'kwame@homelink.gh',
      phone: '+233 24 123 4567',
      rating: 4.8,
      totalRatings: 50,
      completedJobs: 145,
      services: ['Food Delivery', 'Grocery Shopping'],
      location: const LatLng(5.6037, -0.1870), // East Legon, Accra
      address: 'East Legon, Accra',
      bio: 'Professional food delivery service',
      isVerified: true,
      isActive: true,
      profileImageUrl: '',
      certifications: [],
      availability: {},
    ),
    Provider(
      id: '2', 
      name: 'Ama Serwaa',
      email: 'ama@homelink.gh',
      phone: '+233 20 987 6543',
      rating: 4.9,
      totalRatings: 75,
      completedJobs: 203,
      services: ['House Cleaning', 'Laundry Service'],
      location: const LatLng(5.5502, -0.2174), // Osu, Accra
      address: 'Osu, Accra',
      bio: 'Professional house cleaning service',
      isVerified: true,
      isActive: true,
      profileImageUrl: '',
      certifications: [],
      availability: {},
    ),
    Provider(
      id: '3',
      name: 'Kofi Mensah',
      email: 'kofi@homelink.gh',
      phone: '+233 26 555 7890',
      rating: 4.7,
      totalRatings: 30,
      completedJobs: 89,
      services: ['Food Delivery', 'Transportation'],
      location: const LatLng(5.6205, -0.1731), // Airport Residential, Accra
      address: 'Airport Residential, Accra',
      bio: 'Fast delivery and ride services',
      isVerified: true,
      isActive: true,
      profileImageUrl: '',
      certifications: [],
      availability: {},
    ),
    Provider(
      id: '4',
      name: 'Akosua Boateng',
      email: 'akosua@homelink.gh',
      phone: '+233 23 456 7890',
      rating: 4.9,
      totalRatings: 60,
      completedJobs: 167,
      services: ['Nail Tech', 'Makeup Artist'],
      location: const LatLng(5.5557, -0.1963), // Cantonments, Accra
      address: 'Cantonments, Accra',
      bio: 'Professional beauty services',
      isVerified: true,
      isActive: true,
      profileImageUrl: '',
      certifications: [],
      availability: {},
    ),
    Provider(
      id: '5',
      name: 'Yaw Opoku',
      email: 'yaw@homelink.gh',
      phone: '+233 27 123 9876',
      rating: 4.6,
      totalRatings: 40,
      completedJobs: 134,
      services: ['Plumbing', 'Electrical Work'],
      location: const LatLng(5.6434, -0.1776), // Dzorwulu, Accra
      address: 'Dzorwulu, Accra',
      bio: 'Licensed electrician and plumber',
      isVerified: true,
      isActive: true,
      profileImageUrl: '',
      certifications: [],
      availability: {},
    ),
  ];

  Future<List<Provider>> findBestProviders({
    required ServiceRequest request,
    required LatLng customerLocation,
    int maxResults = 5,
  }) async {
    // Get providers from local data service
    final allProviders = await _getProviders();
    
    // Filter providers by service type
    final eligibleProviders = allProviders.where((provider) =>
      provider.services.contains(request.serviceType) && 
      provider.isActive
    ).toList();

    // Calculate scores for each provider
    final scoredProviders = <ScoredProvider>[];
    
    for (final provider in eligibleProviders) {
      final score = _calculateProviderScore(
        provider: provider,
        request: request,
        customerLocation: customerLocation,
      );
      
      scoredProviders.add(ScoredProvider(provider: provider, score: score));
    }

    // Sort by score (highest first) and return top results
    scoredProviders.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredProviders
        .take(maxResults)
        .map((scored) => scored.provider)
        .toList();
  }

  double _calculateProviderScore({
    required Provider provider,
    required ServiceRequest request,
    required LatLng customerLocation,
  }) {
    // Calculate distance in kilometers using Haversine formula
    final distance = _calculateDistance(
      customerLocation.latitude,
      customerLocation.longitude,
      provider.location.latitude,
      provider.location.longitude,
    );

    // Scoring factors (weighted)
    const double ratingWeight = 0.3;
    const double distanceWeight = 0.4;
    const double experienceWeight = 0.2;
    const double responseTimeWeight = 0.1;

    // Rating score (0-1)
    final ratingScore = provider.rating / 5.0;

    // Distance score (closer = better, max useful distance = 20km)
    final distanceScore = max(0, (20 - distance) / 20);

    // Experience score (based on completed jobs, normalized)
    final experienceScore = min(1.0, provider.completedJobs / 200.0);

    // Response time score (faster = better, max useful time = 60 min)
    // Using a default response time based on experience
    final estimatedResponseTime = max(10, 30 - (provider.completedJobs / 10).round());
    final responseTimeScore = max(0, (60 - estimatedResponseTime) / 60);

    // Priority boost for urgent requests
    double urgencyMultiplier = 1.0;
    if (request.isUrgent) {
      urgencyMultiplier = responseTimeScore > 0.7 ? 1.3 : 1.0;
    }

    // Food delivery specific scoring
    double serviceTypeMultiplier = 1.0;
    if (request.serviceType == 'Food Delivery') {
      // Prefer providers with faster response times for food delivery
      serviceTypeMultiplier = 1.0 + (responseTimeScore * 0.2);
    }

    final totalScore = (
      ratingScore * ratingWeight +
      distanceScore * distanceWeight +
      experienceScore * experienceWeight +
      responseTimeScore * responseTimeWeight
    ) * urgencyMultiplier * serviceTypeMultiplier;

    return totalScore;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula to calculate distance between two points
    const double earthRadius = 6371; // km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c; // Distance in km
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<double> calculateETA({
    required Provider provider,
    required LatLng customerLocation,
  }) async {
    // Calculate distance
    final distance = _calculateDistance(
      provider.location.latitude,
      provider.location.longitude,
      customerLocation.latitude,
      customerLocation.longitude,
    );

    // Average speed in Accra traffic (km/h)
    const double averageSpeed = 15; // Accounting for traffic
    
    // Travel time in hours
    final travelTime = distance / averageSpeed;
    
    // Convert to minutes and add estimated provider response time
    final estimatedResponseTime = max(10, 30 - (provider.completedJobs / 10).round());
    final etaMinutes = (travelTime * 60) + estimatedResponseTime;
    
    return etaMinutes;
  }

  Future<List<Provider>> getProvidersNearLocation({
    required LatLng location,
    required String serviceType,
    double radiusKm = 10.0,
  }) async {
    final nearbyProviders = <Provider>[];
    final allProviders = await _getProviders();

    for (final provider in allProviders) {
      if (!provider.services.contains(serviceType)) continue;
      if (!provider.isActive) continue;

      final distance = _calculateDistance(
        location.latitude,
        location.longitude,
        provider.location.latitude,
        provider.location.longitude,
      );

      if (distance <= radiusKm) {
        nearbyProviders.add(provider);
      }
    }

    return nearbyProviders;
  }

  Future<Map<String, dynamic>> getServiceAvailability({
    required LatLng location,
    required String serviceType,
  }) async {
    final nearbyProviders = await getProvidersNearLocation(
      location: location,
      serviceType: serviceType,
    );

    final availableCount = nearbyProviders.where((p) => p.isActive).length;
    final averageRating = nearbyProviders.isEmpty ? 0.0 :
        nearbyProviders.map((p) => p.rating).reduce((a, b) => a + b) / nearbyProviders.length;

    double estimatedWaitTime = 0;
    if (nearbyProviders.isNotEmpty) {
      final fastestProvider = nearbyProviders.reduce((a, b) =>
          a.completedJobs > b.completedJobs ? a : b); // Use experience as proxy for response time
      estimatedWaitTime = await calculateETA(
        provider: fastestProvider,
        customerLocation: location,
      );
    }

    return {
      'availableProviders': availableCount,
      'averageRating': averageRating,
      'estimatedWaitTime': estimatedWaitTime,
      'providers': nearbyProviders,
    };
  }
}

class ScoredProvider {
  final Provider provider;
  final double score;

  ScoredProvider({required this.provider, required this.score});
}