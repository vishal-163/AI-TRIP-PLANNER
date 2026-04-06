import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final apiKey = 'AIzaSyAcx9MepqrdoWIbi-9aSDVEbsTW6F6j1Mk';
  final modelName = 'gemini-2.5-flash';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey';
  
  final prompt = '''
Create a 3-day travel itinerary for a trip with these details:
Destinations: Paris
Origin: New York
Dates: 2026-06-01 to 2026-06-03
Travelers: 2
Budget: ₹50000
Interests: history, food

PROVIDE ONLY REAL PLACES AND ACTUAL COSTS AND ACTUAL COORDINATES FOR LOCATIONS(ACCURATE TO 20 METRES)- NO GENERIC TERMS OR MOCK DATA!
PROVIDE DETAILED, ENGAGING DESCRIPTIONS FOR EACH ACTIVITY AND DO NOT MISS IMPORTANT MUST VISIT SPOTS IN THE DESTINATION AND SHOULD BE OF TOP PRIORITY AND REMEMBER TO PROVIDE EVEN ACTUAL RESTAURANTS WITH NAMES AND COORDINATESNEARBY TO VISITED PLACES(AT LEAST 30-40 WORDS).

Return a JSON response with exactly this structure:
{
  "summary": {
    "tripTitle": "Descriptive title including destinations",
    "origin": "New York",
    "destinations": ["Paris"],
    "startDate": "2026-06-01T00:00:00.000",
    "endDate": "2026-06-03T00:00:00.000",
    "numberOfTravelers": 2,
    "interests": ["history", "food"]
  },
  "dailyItinerary": [
    {
      "dayNumber": 1,
      "date": "2026-06-01T00:00:00.000",
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
    "totalEstimatedCost": 50000.0,
    "perPersonCost": 25000.0,
    "costBreakdown": {
      "accommodation": 20000.0,
      "food": 12500.0,
      "transportation": 7500.0,
      "activities": 7500.0,
      "shopping": 2500.0,
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
5. IF MULTIPLE DESTINATIONS ARE PROVIDED (Paris), SPLIT THE DAYS LOGICALLY BETWEEN THEM.
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
    );

    print('Status code: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Error body: ${response.body}');
    } else {
      print('Success!');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse['candidates'][0]['content']['parts'][0]['text'].substring(0, 100)); // Print start of response
    }
  } catch (e) {
    print('Error: $e');
  }
}
