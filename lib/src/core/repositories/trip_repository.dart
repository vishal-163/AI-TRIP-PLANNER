import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/trip_input_model.dart';
import '../models/itinerary_model.dart';
import '../services/gemini_service.dart';

abstract class TripRepository {
  Future<ItineraryModel> generateItinerary(TripInputModel tripInput);
  Future<ItineraryModel?> getCachedItinerary();
  Future<void> cacheItinerary(ItineraryModel itinerary);
}

class TripRepositoryImpl implements TripRepository {
  @override
  Future<ItineraryModel> generateItinerary(TripInputModel tripInput) async {
    debugPrint('Using Gemini API for itinerary generation');
    try {
      final result = await GeminiService.generateItinerary(tripInput);
      debugPrint('Successfully generated itinerary using Gemini');
      return result;
    } catch (e) {
      debugPrint('Failed to generate itinerary using Gemini: $e');
      rethrow;
    }
  }

  @override
  Future<ItineraryModel?> getCachedItinerary() async {
    return null;
  }

  @override
  Future<void> cacheItinerary(ItineraryModel itinerary) async {
    debugPrint('Caching itinerary: ${itinerary.summary.tripTitle}');
  }
}