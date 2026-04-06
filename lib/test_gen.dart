import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/core/services/gemini_service.dart';
import 'src/core/models/trip_input_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  // Load dotenv if needed, or set it directly
  dotenv.env['GEMINI_API_KEY'] = 'AIzaSyD2rbr7Ky7Uq3SpTVj5V9IKA9wZjRlhPeI';

  final tripInput = TripInputModel(
    origin: 'New York',
    destinations: ['Paris'],
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 3)),
    budgetLevel: 'medium',
    numberOfTravelers: 2,
    interests: ['history', 'food'],
    specialConstraints: '',
  );

  try {
    print('Calling GeminiService.generateItinerary...');
    final result = await GeminiService.generateItinerary(tripInput);
    print('Success!');
    print(result.summary.tripTitle);
  } catch (e) {
    print('Failed to generate itinerary: \$e');
  }
}
