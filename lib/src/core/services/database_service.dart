import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/itinerary_model.dart';
import '../models/trip_input_model.dart';

class DatabaseService {
  static const String _supabaseUrl = 'https://cizfpaaybfydvotwvbku.supabase.co';
  static const String _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpemZwYWF5YmZ5ZHZvdHd2Ymt1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1OTY2MTUsImV4cCI6MjA3ODE3MjYxNX0.SG33hxj0LUDg8r22ycsRXDwLJwbebDIoWSuLKNiDSys';

  static final DatabaseService _instance = DatabaseService._internal();
  SupabaseClient? _client;
  bool _isInitializing = false;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    if (_client != null) {
      print('Supabase client already initialized');
      return; // Already initialized
    }
    
    if (_isInitializing) {
      print('Supabase client is already initializing, waiting...');
      // Wait for initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    
    _isInitializing = true;
    try {
      print('Initializing Supabase client...');
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseKey,
      );
      _client = Supabase.instance.client;
      print('Supabase client initialized successfully');
    } catch (e) {
      print('Failed to initialize Supabase client: $e');
      _client = null; // Reset client on failure
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('DatabaseService not initialized. Call initialize() first.');
    }
    return _client!;
  }

  // Phone Auth Methods

  /// Send OTP to phone number
  Future<void> signInWithPhone(String phone, {bool shouldCreateUser = true}) async {
    try {
      await initialize();
      await client.auth.signInWithOtp(
        phone: phone,
        shouldCreateUser: shouldCreateUser,
      );
      print('OTP sent to $phone');
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyPhoneOtp(String phone, String token) async {
    try {
      await initialize();
      final response = await client.auth.verifyOTP(
        type: OtpType.sms,
        token: token,
        phone: phone,
      );
      print('OTP verified successfully');
      return response;
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  // Email Auth Methods

  /// Send OTP to email
  Future<void> signInWithEmail(String email, {bool shouldCreateUser = true}) async {
    try {
      await initialize();
      await client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: shouldCreateUser,
      );
      print('OTP sent to $email');
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  /// Verify Email OTP
  Future<AuthResponse> verifyEmailOtp(String email, String token) async {
    try {
      await initialize();
      final response = await client.auth.verifyOTP(
        type: OtpType.email,
        token: token,
        email: email,
      );
      print('OTP verified successfully');
      return response;
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  /// Update user metadata (name, phone)
  Future<void> updateUserMetadata({String? name, String? phone}) async {
    try {
      await initialize();
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{};
      if (name != null) {
        updates['full_name'] = name;
        updates['name'] = name; // Standard key for Supabase Dashboard display
      }
      if (phone != null) updates['phone'] = phone; // Store phone in metadata

      if (updates.isNotEmpty) {
        print('Attempting to update user metadata with: $updates');
        final response = await client.auth.updateUser(
          UserAttributes(
            data: updates,
            // phone: phone, // REMOVED: Do not update Auth Phone identity, just store in metadata
          ),
        );
        print('User metadata updated successfully. Response user metadata: ${response.user?.userMetadata}');
      } else {
        print('No updates to send for user metadata');
      }
    } catch (e) {
      print('CRITICAL ERROR updating user metadata: $e');
      rethrow; // Rethrow so UI knows it failed
    }
  }

  /// Initialize the database (no-op for Supabase as tables are created in the dashboard)
  Future<void> initializeDatabase() async {
    print('Initializing database...');
    // Tables are created in Supabase dashboard, so no initialization needed here
    await initialize();
    print('Database initialized successfully');
  }

  /// Save a trip to Supabase
  Future<void> saveTrip(ItineraryModel itinerary, TripInputModel tripInput) async {
    try {
      print('Starting trip save process...');
      
      // Ensure client is initialized
      await initialize();
      
      // Validate input data
      if (tripInput.origin.isEmpty) {
        throw Exception('Origin cannot be empty');
      }
      
      if (tripInput.destinations.isEmpty) {
        throw Exception('Destinations cannot be empty');
      }
      
      // Save trip input data
      final tripData = {
        'origin': tripInput.origin,
        'destinations': tripInput.destinations,
        'start_date': tripInput.startDate.toIso8601String(),
        'end_date': tripInput.endDate.toIso8601String(),
        'budget_level': tripInput.budgetLevel,
        'number_of_travelers': tripInput.numberOfTravelers,
        'interests': tripInput.interests,
        'special_constraints': tripInput.specialConstraints ?? '',
        'trip_title': itinerary.summary.tripTitle,
      };

      print('Saving trip data: $tripData');
      
      final tripResponse = await client
          .from('trips')
          .insert(tripData)
          .select()
          .single();

      final tripId = tripResponse['id'];
      print('Trip saved with ID: $tripId');

      // Save daily itinerary
      for (final day in itinerary.dailyItinerary) {
        final dayData = {
          'trip_id': tripId,
          'day_number': day.dayNumber,
          'date': day.date.toIso8601String(),
          'title': day.title,
        };

        print('Saving day data: $dayData');
        final dayResponse = await client
            .from('daily_itinerary')
            .insert(dayData)
            .select()
            .single();

        final dayId = dayResponse['id'];
        print('Day saved with ID: $dayId');

      // Save activities for this day
        try {
          for (final activity in day.activities) {
            final activityData = {
              'daily_itinerary_id': dayId,
              'time': activity.time,
              'title': activity.title,
              'description': activity.description ?? '',
              'category': activity.category,
              'location': activity.location ?? '',
              'latitude': activity.latitude ?? 0.0,
              'longitude': activity.longitude ?? 0.0,
              'duration_minutes': activity.durationMinutes ?? 0,
              'cost': activity.cost ?? 0.0,
            };

            print('Saving activity data: $activityData');
            await client.from('activities').insert(activityData);
          }
        } catch (e) {
          print('Error saving activities for day $dayId: $e');
          // Continue saving other days/data
        }
      }

      // Save recommendations
      try {
        for (final recommendation in itinerary.recommendations) {
          final recommendationData = {
            'trip_id': tripId,
            'name': recommendation.name,
            'category': recommendation.category,
            'description': recommendation.description ?? '',
            'address': recommendation.address ?? '',
            'latitude': recommendation.latitude ?? 0.0,
            'longitude': recommendation.longitude ?? 0.0,
            'rating': recommendation.rating ?? 0.0,
            'average_cost': recommendation.averageCost ?? 0.0,
            'image_url': recommendation.imageUrl ?? '',
          };

          print('Saving recommendation data: $recommendationData');
          await client.from('recommendations').insert(recommendationData);
        }
      } catch (e) {
        print('Error saving recommendations: $e');
      }

      // Save budget estimate
      try {
        final budgetData = {
          'trip_id': tripId,
          'total_estimated_cost': itinerary.estimatedBudget.totalEstimatedCost,
          'per_person_cost': itinerary.estimatedBudget.perPersonCost,
          'cost_breakdown': itinerary.estimatedBudget.costBreakdown,
        };

        print('Saving budget data: $budgetData');
        await client.from('budget_estimates').insert(budgetData);
      } catch (e) {
        print('Error saving budget estimate: $e');
      }

      // Save travel tips
      try {
        if (itinerary.travelTips != null) {
          for (final tip in itinerary.travelTips!) {
            final tipData = {
              'trip_id': tripId,
              'title': tip.title,
              'description': tip.description ?? '',
            };

            print('Saving tip data: $tipData');
            await client.from('travel_tips').insert(tipData);
          }
        }
      } catch (e) {
        print('Error saving travel tips: $e');
      }
      
      print('Trip saved successfully to Supabase');
    } catch (e, stackTrace) {
      print('Error saving trip to Supabase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all trips from Supabase
  Future<List<Map<String, dynamic>>> getAllTrips() async {
    try {
      print('Fetching all trips from Supabase...');
      
      // Ensure client is initialized
      await initialize();
      
      final response = await client
          .from('trips')
          .select()
          .order('created_at', ascending: false);
      
      print('Fetched ${response.length} trips');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('Error fetching trips from Supabase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get a specific trip by ID with all related data
  Future<Map<String, dynamic>?> getFullTripById(String tripId) async {
    try {
      print('Fetching full trip with ID: $tripId');
      
      // Ensure client is initialized
      await initialize();
      
      // Get the main trip data
      final tripResponse = await client
          .from('trips')
          .select()
          .eq('id', tripId)
          .single();
      
      // Get daily itinerary
      final dailyItineraryResponse = await client
          .from('daily_itinerary')
          .select()
          .eq('trip_id', tripId)
          .order('day_number');
      
      // Get activities for each day
      final List<Map<String, dynamic>> dailyItineraryWithActivities = [];
      for (var day in dailyItineraryResponse) {
        final activitiesResponse = await client
            .from('activities')
            .select()
            .eq('daily_itinerary_id', day['id'])
            .order('time');
        
        day['activities'] = activitiesResponse;
        dailyItineraryWithActivities.add(day);
      }
      
      // Get recommendations
      final recommendationsResponse = await client
          .from('recommendations')
          .select()
          .eq('trip_id', tripId);
      
      // Get budget estimate
      final budgetResponse = await client
          .from('budget_estimates')
          .select()
          .eq('trip_id', tripId)
          .single();
      
      // Get travel tips
      final tipsResponse = await client
          .from('travel_tips')
          .select()
          .eq('trip_id', tripId);
      
      // Combine all data
      final fullTripData = {
        'trip': tripResponse,
        'daily_itinerary': dailyItineraryWithActivities,
        'recommendations': recommendationsResponse,
        'budget_estimate': budgetResponse,
        'travel_tips': tipsResponse,
      };
      
      print('Full trip fetched successfully');
      return fullTripData;
    } catch (e, stackTrace) {
      print('Error fetching full trip from Supabase: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get a specific trip by ID
  Future<Map<String, dynamic>?> getTripById(String tripId) async {
    try {
      print('Fetching trip with ID: $tripId');
      
      // Ensure client is initialized
      await initialize();
      
      final response = await client
          .from('trips')
          .select()
          .eq('id', tripId)
          .single();
      
      print('Trip fetched successfully');
      return response;
    } catch (e, stackTrace) {
      print('Error fetching trip from Supabase: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Delete a trip by ID
  Future<void> deleteTrip(String tripId) async {
    try {
      print('Deleting trip with ID: $tripId');
      
      // Ensure client is initialized
      await initialize();
      
      await client
          .from('trips')
          .delete()
          .eq('id', tripId);
      
      print('Trip deleted successfully');
    } catch (e, stackTrace) {
      print('Error deleting trip from Supabase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}