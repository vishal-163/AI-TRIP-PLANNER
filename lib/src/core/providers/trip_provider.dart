import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/trip_input_model.dart';
import '../models/itinerary_model.dart';
import '../repositories/trip_repository.dart';

// State provider for the generated itinerary
final itineraryProvider = StateProvider<ItineraryModel?>((ref) => null);

// State provider for trip input
final tripInputProvider = StateProvider<TripInputModel?>((ref) => null);

// Repository provider
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl();
});

// Database repository provider (placeholder)
final tripDatabaseRepositoryProvider = Provider((ref) {
  // In a real implementation, this would return a database repository
  return _MockDatabaseRepository();
});

class _MockDatabaseRepository {
  Future<void> initializeDatabase() async {
    // Mock implementation
    debugPrint('Initializing database...');
  }
  
  Future<void> saveTrip(ItineraryModel itinerary, TripInputModel tripInput) async {
    // Mock implementation
    debugPrint('Saving trip to database...');
  }
}

final generateItineraryProvider = FutureProvider.family<ItineraryModel, TripInputModel>((ref, tripInput) async {
  print('Generating itinerary using Gemini API for trip input: ${tripInput.origin} -> ${tripInput.destinations}');
  
  final repository = ref.read(tripRepositoryProvider);
  final databaseRepository = ref.read(tripDatabaseRepositoryProvider);
  
  // Initialize database
  try {
    print('Initializing database...');
    await databaseRepository.initializeDatabase();
    print('Database initialized successfully');
  } catch (e) {
    print('Failed to initialize database: $e');
  }
  
  try {
    final itinerary = await repository.generateItinerary(tripInput);
    print('Itinerary generated successfully using Gemini API');
    
    // Cache the itinerary
    await repository.cacheItinerary(itinerary);
    print('Itinerary cached successfully');
    
    // Save to database
    try {
      print('Saving itinerary to database...');
      await databaseRepository.saveTrip(itinerary, tripInput);
      print('Trip saved successfully to database');
    } catch (e, stackTrace) {
      // Log error but don't fail the operation
      print('Failed to save trip to database: $e');
      print('Stack trace: $stackTrace');
      // In a production app, you might want to show a notification
      // For now, we'll just print the error
    }
    
    // Update the state providers
    ref.read(itineraryProvider.notifier).state = itinerary;
    ref.read(tripInputProvider.notifier).state = tripInput;
    print('Itinerary and trip input providers updated');
    
    return itinerary;
  } catch (e, stackTrace) {
    print('Failed to generate itinerary with Gemini: $e');
    print('Stack trace: $stackTrace');
    
    // Provide service-specific error messages
    String userMessage = 'Failed to generate itinerary with Gemini. ';
    
    // Use the specific error message from the service if available
    if (e is Exception) {
      final errorMessage = e.toString();
      // Remove the "Exception:" prefix if present
      final cleanMessage = errorMessage.startsWith('Exception:') 
          ? errorMessage.substring(11).trim() 
          : errorMessage;
      
      // If the service provided a specific error message, use it
      if (cleanMessage != 'Failed to generate itinerary: $e') {
        throw Exception('Gemini error: $cleanMessage');
      }
    }
    
    // Specific error handling for each service
    if (e.toString().contains('quota') || e.toString().contains('429')) {
      userMessage += 'API quota exceeded. Please try again later.';
    } else if (e.toString().contains('API key')) {
      userMessage += 'Please check your API key in the .env file.';
    } else if (e.toString().contains('timeout')) {
      userMessage += 'Request timed out. Please check your internet connection and try again.';
    } else if (e.toString().contains('Network') || e.toString().contains('SocketException')) {
      userMessage += 'Network error. Please check your internet connection and try again.';
    } else {
      // Use the original error message if it's more specific
      userMessage = e.toString().length > 50 
          ? 'Failed to generate itinerary with Gemini: ${e.toString().substring(0, 50)}...' 
          : 'Gemini error: ${e.toString()}';
    }
    
    // Throw a more user-friendly error
    throw Exception(userMessage);
  }
});

// Add a provider for forcing refresh
final refreshItineraryProvider = StateProvider<bool>((ref) => false);