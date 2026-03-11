import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  // Read the API key from the .env file
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('.env file not found');
    return;
  }
  
  final envContent = await envFile.readAsString();
  final lines = envContent.split('\n');
  String? apiKey;
  
  for (final line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.substring('GEMINI_API_KEY='.length).trim();
      break;
    }
  }
  
  if (apiKey == null || apiKey.isEmpty) {
    print('GEMINI_API_KEY not found in .env file');
    return;
  }
  
  print('Using API key: ${apiKey.substring(0, 10)}...'); // Print first 10 characters for verification
  
  // Test endpoint with the gemini-flash-latest model (should be more available)
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey';
  
  final prompt = '''
You are a professional travel planner. Create a simple 1-day travel itinerary for Paris, France for 2 people with interests in Art and Food.
Return ONLY valid JSON with this exact structure:
{
  "summary": {
    "tripTitle": "1-Day Trip to Paris",
    "origin": "New York",
    "destinations": ["Paris"],
    "startDate": "2024-06-01",
    "endDate": "2024-06-01",
    "numberOfTravelers": 2,
    "interests": ["Art", "Food"]
  },
  "dailyItinerary": [
    {
      "dayNumber": 1,
      "date": "2024-06-01",
      "title": "Day 1 in Paris",
      "activities": [
        {
          "time": "9:00 AM - 11:00 AM",
          "title": "Eiffel Tower",
          "description": "Visit the iconic Eiffel Tower",
          "category": "sightseeing",
          "location": "Eiffel Tower, Paris",
          "latitude": 48.8584,
          "longitude": 2.2945,
          "durationMinutes": 120,
          "cost": 25.0
        }
      ]
    }
  ],
  "recommendations": [
    {
      "name": "Eiffel Tower",
      "category": "attraction",
      "description": "Iconic landmark of Paris",
      "address": "Champ de Mars, 5 Av. Anatole France, 75007 Paris, France",
      "latitude": 48.8584,
      "longitude": 2.2945,
      "rating": 4.5,
      "averageCost": 25.0,
      "imageUrl": "https://example.com/eiffel.jpg"
    }
  ],
  "estimatedBudget": {
    "totalEstimatedCost": 100.0,
    "perPersonCost": 50.0,
    "costBreakdown": {
      "accommodation": 40.0,
      "food": 30.0,
      "transportation": 15.0,
      "activities": 10.0,
      "shopping": 5.0,
      "miscellaneous": 0.0
    }
  },
  "travelTips": [
    {
      "title": "Best Time to Visit",
      "description": "Visit early morning to avoid crowds"
    }
  ]
}
''';
  
  try {
    print('Sending request to: $url');
    
    final request = HttpClient();
    final uri = Uri.parse(url);
    final httpClientRequest = await request.postUrl(uri);
    httpClientRequest.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({
      'contents': [{
        'parts': [{'text': prompt}]
      }],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
      }
    });
    
    httpClientRequest.write(body);
    final response = await httpClientRequest.close();
    
    print('Response status: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('Response body: $responseBody');
    
    if (response.statusCode == 200) {
      print('API call successful!');
      final data = jsonDecode(responseBody);
      print('Response data: $data');
    } else {
      print('API call failed with status: ${response.statusCode}');
    }
    
    request.close();
  } catch (e) {
    print('Error occurred: $e');
  }
}