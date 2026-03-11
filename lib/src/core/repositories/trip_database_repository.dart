import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/itinerary_model.dart';
import '../models/trip_input_model.dart';

// Use the singleton instance of DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final tripDatabaseRepositoryProvider = Provider<TripDatabaseRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return TripDatabaseRepository(databaseService);
});

class TripDatabaseRepository {
  final DatabaseService _databaseService;

  TripDatabaseRepository(this._databaseService);

  /// Initialize the database
  Future<void> initializeDatabase() async {
    await _databaseService.initializeDatabase();
  }

  /// Save a trip to the database
  Future<void> saveTrip(ItineraryModel itinerary, TripInputModel tripInput) async {
    await _databaseService.saveTrip(itinerary, tripInput);
  }

  /// Get all trips from the database
  Future<List<Map<String, dynamic>>> getAllTrips() async {
    return await _databaseService.getAllTrips();
  }

  /// Get a specific trip by ID with all related data
  Future<Map<String, dynamic>?> getFullTripById(String tripId) async {
    return await _databaseService.getFullTripById(tripId);
  }

  /// Get a specific trip by ID
  Future<Map<String, dynamic>?> getTripById(String tripId) async {
    return await _databaseService.getTripById(tripId);
  }

  /// Delete a trip by ID
  Future<void> deleteTrip(String tripId) async {
    await _databaseService.deleteTrip(tripId);
  }
}