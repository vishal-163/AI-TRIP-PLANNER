import 'package:flutter/foundation.dart';
import 'package:ai_trip_planner/src/core/models/trip_input_model.dart';
import 'package:ai_trip_planner/src/core/services/gemini_service.dart';

void main() async {
  final tripInput = TripInputModel(
    origin: 'Bangalore, Karnataka',
    destinations: ['Tirupati, Andhra Pradesh'],
    startDate: DateTime(2024, 6, 1),
    endDate: DateTime(2024, 6, 3),
    numberOfTravelers: 2,
    budgetLevel: '₹15000',
    interests: ['Religious', 'Cultural', 'Food'],
    specialConstraints: 'None',
  );

  debugPrint('Testing AI services with trip: ${tripInput.origin} to ${tripInput.destinations.join(', ')}');

  // Test Gemini service
  try {
    debugPrint('Testing Gemini service...');
    final geminiItinerary = await GeminiService.generateItinerary(tripInput);
    debugPrint('Gemini itinerary generated successfully:');
    debugPrint('Title: ${geminiItinerary.summary.tripTitle}');
    debugPrint('Days: ${geminiItinerary.dailyItinerary.length}');
    debugPrint('Activities on Day 1: ${geminiItinerary.dailyItinerary[0].activities.length}');
    debugPrint('Recommendations: ${geminiItinerary.recommendations.length}');
    debugPrint('Travel Tips: ${geminiItinerary.travelTips?.length ?? 0}');
  } catch (e) {
    debugPrint('Gemini service failed: $e');
  }

  // Remove OpenRouter service test
}