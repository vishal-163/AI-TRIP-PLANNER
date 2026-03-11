import 'package:flutter/material.dart';
import 'package:ai_trip_planner/src/core/services/gemini_service.dart';
import 'package:ai_trip_planner/src/core/models/trip_input_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  final tripInput = TripInputModel(
    origin: 'New York',
    destinations: ['Paris'],
    startDate: DateTime(2024, 6, 1),
    endDate: DateTime(2024, 6, 5),
    numberOfTravelers: 2,
    interests: ['Art', 'Food', 'History'],
    budgetLevel: 'Mid-range',
    specialConstraints: 'None',
  );

  try {
    print('Testing Gemini service...');
    final itinerary = await GeminiService.generateItinerary(tripInput);
    print('Success! Generated itinerary:');
    print('Title: ${itinerary.summary.tripTitle}');
    print('Days: ${itinerary.dailyItinerary.length}');
    print('Recommendations: ${itinerary.recommendations.length}');
    print('Travel Tips: ${itinerary.travelTips?.length ?? 0}');
  } catch (e) {
    print('Error: $e');
  }
}