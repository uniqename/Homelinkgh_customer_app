import 'dart:math';
import 'package:homelinkgh_customer/models/location.dart';
import '../models/provider.dart';
import '../models/service_request.dart';

class SmartSelectionService {
  static final SmartSelectionService _instance = SmartSelectionService._internal();
  factory SmartSelectionService() => _instance;
  SmartSelectionService._internal();

  // Mock provider data for Ghana
  final List<Provider> _providers = [
    Provider(
      id: '1',
      name: 'Kwame Asante',
      rating: 4.8,
      completedJobs: 145,
      services: ['Food Delivery', 'Grocery Shopping'],
      location: const LatLng(5.6037, -0.1870), // East Legon, Accra
      isAvailable: true,
      averageResponseTime: 15, // minutes
    ),
    Provider(
      id: '2', 
      name: 'Ama Serwaa',
      rating: 4.9,
      completedJobs: 203,
      services: ['House Cleaning', 'Laundry Service'],
      location: const LatLng(5.5502, -0.2174), // Osu, Accra
      isAvailable: true,
      averageResponseTime: 12,
    ),
    Provider(
      id: '3',
      name: 'Kofi Mensah', 
      rating: 4.7,
      completedJobs: 89,
      services: ['Food Delivery', 'Transportation'],
      location: const LatLng(5.6205, -0.1731), // Airport Residential, Accra
      isAvailable: true,
      averageResponseTime: 8,
    ),
    Provider(
      id: '4',
      name: 'Akosua Boateng',
      rating: 4.9,
      completedJobs: 167,
      services: ['Nail Tech', 'Makeup Artist'],
      location: const LatLng(5.5557, -0.1963), // Cantonments, Accra
      isAvailable: true,
      averageResponseTime: 20,
    ),
    Provider(
      id: '5',
      name: 'Yaw Opoku',
      rating: 4.6,
      completedJobs: 134,
      services: ['Plumbing', 'Electrical Work'],
      location: const LatLng(5.6434, -0.1776), // Dzorwulu, Accra
      isAvailable: true,
      averageResponseTime: 25,
    ),
  ];

  Future<List<Provider>> findBestProviders({
    required ServiceRequest request,
    required LatLng customerLocation,
    int maxResults = 5,
  }) async {
    // Filter providers by service type
    final eligibleProviders = _providers.where((provider) =>
      provider.services.contains(request.serviceType) && 
      provider.isAvailable
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
    final responseTimeScore = max(0, (60 - provider.averageResponseTime) / 60);

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
    
    // Convert to minutes and add provider response time
    final etaMinutes = (travelTime * 60) + provider.averageResponseTime;
    
    return etaMinutes;
  }

  Future<List<Provider>> getProvidersNearLocation({
    required LatLng location,
    required String serviceType,
    double radiusKm = 10.0,
  }) async {
    final nearbyProviders = <Provider>[];

    for (final provider in _providers) {
      if (!provider.services.contains(serviceType)) continue;
      if (!provider.isAvailable) continue;

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

    final availableCount = nearbyProviders.where((p) => p.isAvailable).length;
    final averageRating = nearbyProviders.isEmpty ? 0.0 :
        nearbyProviders.map((p) => p.rating).reduce((a, b) => a + b) / nearbyProviders.length;

    double estimatedWaitTime = 0;
    if (nearbyProviders.isNotEmpty) {
      final fastestProvider = nearbyProviders.reduce((a, b) =>
          a.averageResponseTime < b.averageResponseTime ? a : b);
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