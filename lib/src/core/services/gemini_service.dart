import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/itinerary_model.dart';
import '../models/trip_input_model.dart';

class GeminiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  

  static const List<String> _modelsToTry = [
    'gemini-2.0-flash', 
    'gemini-2.0-flash-lite',     
    'gemini-flash-latest',  
    'gemini-2.5-flash',      
  ];

  static Future<ItineraryModel> generateItinerary(TripInputModel tripInput) async {
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    Exception? lastError;

    for (final modelName in _modelsToTry) {
      try {
        print('Attempting to generate itinerary using model: $modelName');
        return await _generateWithModel(tripInput, modelName);
      } catch (e) {
        print('Model $modelName failed: $e');
        lastError = e is Exception ? e : Exception(e.toString());
        
      }
    }

    throw Exception('All Gemini models failed. Last error: $lastError. Please check your internet connection or API key.');
  }

  static Future<ItineraryModel> _generateWithModel(TripInputModel tripInput, String modelName) async {
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey';
    
    final days = tripInput.endDate.difference(tripInput.startDate).inDays + 1;
    final budget = _extractBudgetValue(tripInput.budgetLevel) ?? 
                  _mapBudgetLevelToValue(tripInput.budgetLevel, tripInput.numberOfTravelers, days);
    
    final destinationsList = tripInput.destinations.join(', ');
    
    final prompt = '''
Create a ${days}-day travel itinerary for a trip with these details:
Destinations: $destinationsList
Origin: ${tripInput.origin}
Dates: ${tripInput.startDate.toString().split(' ')[0]} to ${tripInput.endDate.toString().split(' ')[0]}
Travelers: ${tripInput.numberOfTravelers}
Budget: ₹$budget
Interests: ${tripInput.interests.join(', ')}

PROVIDE ONLY REAL PLACES AND ACTUAL COSTS AND ACTUAL COORDINATES FOR LOCATIONS(ACCURATE TO 20 METRES)- NO GENERIC TERMS OR MOCK DATA!
PROVIDE DETAILED, ENGAGING DESCRIPTIONS FOR EACH ACTIVITY AND DO NOT MISS IMPORTANT MUST VISIT SPOTS IN THE DESTINATION AND SHOULD BE OF TOP PRIORITY AND REMEMBER TO PROVIDE EVEN ACTUAL RESTAURANTS WITH NAMES AND COORDINATESNEARBY TO VISITED PLACES(AT LEAST 30-40 WORDS).

Return a JSON response with exactly this structure:
{
  "summary": {
    "tripTitle": "Descriptive title including destinations",
    "origin": "${tripInput.origin}",
    "destinations": ["${tripInput.destinations.join('", "')}"],
    "startDate": "${tripInput.startDate.toIso8601String()}",
    "endDate": "${tripInput.endDate.toIso8601String()}",
    "numberOfTravelers": ${tripInput.numberOfTravelers},
    "interests": ["${tripInput.interests.join('", "')}"]
  },
  "dailyItinerary": [
    {
      "dayNumber": 1,
      "date": "${tripInput.startDate.toIso8601String()}",
      "title": "Day 1 in [City Name]",
      "activities": [
        {
          "time": "9:00 AM - 11:00 AM",
          "title": "Real specific place name",
          "description": "Detailed description of the place, its history, or what to do there.",
          "category": "sightseeing",
          "location": "Real address",
          "latitude": 12.3456,
          "longitude": 78.9012,
          "durationMinutes": 120,
          "cost": 0.0
        }
      ]
    }
  ],
  "recommendations": [
    {
      "name": "Real place name",
      "category": "attraction",
      "description": "Detailed description",
      "address": "Real address",
      "latitude": 12.3456,
      "longitude": 78.9012,
      "rating": 4.5,
      "averageCost": 100.0,
      "imageUrl": "https://example.com/real_image.jpg"
    }
  ],
  "estimatedBudget": {
    "totalEstimatedCost": $budget,
    "perPersonCost": ${(budget / tripInput.numberOfTravelers).toDouble()},
    "costBreakdown": {
      "accommodation": ${(budget * 0.4).roundToDouble()},
      "food": ${(budget * 0.25).roundToDouble()},
      "transportation": ${(budget * 0.15).roundToDouble()},
      "activities": ${(budget * 0.15).roundToDouble()},
      "shopping": ${(budget * 0.05).roundToDouble()},
      "miscellaneous": 0.0
    }
  },
  "travelTips": [
    {
      "title": "Tip Title",
      "description": "Detailed practical tip"
    }
  ]
}

CRITICAL REQUIREMENTS:
1. USE ONLY REAL PLACES WITH ACTUAL NAMES.
2. PROVIDE REAL ADDRESSES AND GEOGRAPHIC COORDINATES.
3. INCLUDE ACTUAL COSTS IN INDIAN RUPEES.
4. ENSURE EXACTLY 4 ACTIVITIES PER DAY. NO MORE, NO LESS.
5. IF MULTIPLE DESTINATIONS ARE PROVIDED ($destinationsList), SPLIT THE DAYS LOGICALLY BETWEEN THEM.
6. RESPECT THE BUDGET CONSTRAINTS.
7. RETURN ONLY VALID JSON. DO NOT INCLUDE MARKDOWN FORMATTING.
8. ESCAPE ALL SPECIAL CHARACTERS IN STRINGS PROPERLY.
9. PROVIDE RICH, DETAILED DESCRIPTIONS FOR ALL ACTIVITIES.
''';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.5,
        'maxOutputTokens': 8192,
        'responseMimeType': 'application/json'
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final textContent = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        
        // Clean and parse JSON
        String jsonString = _cleanJsonString(textContent);
        
        try {
          final itineraryJson = jsonDecode(jsonString);
          return ItineraryModel.fromJson(itineraryJson);
        } catch (e) {
          // If parsing fails, try to repair the JSON string
           print('JSON parsing failed: $e. Attempting to repair...');
           // Simple repair: ensure it ends with }
           if (!jsonString.endsWith('}')) {
             jsonString += '}';
           }
           // Try parsing again
           try {
             final itineraryJson = jsonDecode(jsonString);
             return ItineraryModel.fromJson(itineraryJson);
           } catch (retryError) {
             throw Exception('Failed to parse itinerary data: $e');
           }
        }
      } else {
        throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Error generating itinerary: $e');
    }
  }

  static String _cleanJsonString(String jsonString) {
    String cleaned = jsonString.trim();
    
    // Remove markdown code blocks
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    
    cleaned = cleaned.trim();
    return cleaned;
  }

  static int? _extractBudgetValue(String budgetLevel) {
    final RegExp budgetRegex = RegExp(r'(\d+)');
    final Match? match = budgetRegex.firstMatch(budgetLevel);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }
  
  static int _mapBudgetLevelToValue(String budgetLevel, int numberOfTravelers, int days) {
    final Map<String, double> budgetMultipliers = {
      'low': 1000.0,
      'medium': 2500.0,
      'high': 5000.0,
    };
    
    final multiplier = budgetMultipliers[budgetLevel.toLowerCase()] ?? 2500.0;
    return (multiplier * numberOfTravelers * days).toInt();
  }
}