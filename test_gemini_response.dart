import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Simple test to validate Gemini API response format
Future<void> main() async {
  // Replace with your actual API key
  final apiKey = 'AIzaSyARMFKMq4kZHM4oMtUECAjRFdMtrAY-0Gw';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
  
  final prompt = '''
Create a detailed travel itinerary for a trip from Bangalore to Tirupati.
Dates: 2023-12-01 to 2023-12-03 (3 days)
Travelers: 2
Budget: ₹15000.00 total (₹7500.00 per person)
Interests: temple, sightseeing, local food

Instructions for fast response:
1. Create an itinerary for ALL 3 days with 3-4 detailed activities each day (focus on quality over quantity)
2. Use real places for the destination Tirupati
3. Keep total cost within the budget of ₹15000.00
4. Include specific times, durations, and costs for each activity
5. Provide 3-4 detailed travel tips for the destination
6. Include 2-3 detailed recommendations for places to visit
7. Be concise but informative - avoid unnecessary fluff
8. Return ONLY valid JSON - no other text

JSON format:
{
  "summary": {
    "tripTitle": "Trip to Tirupati",
    "origin": "Bangalore",
    "destinations": ["Tirupati"],
    "startDate": "2023-12-01",
    "endDate": "2023-12-03",
    "numberOfTravelers": 2,
    "interests": ["temple", "sightseeing", "local food"]
  },
  "dailyItinerary": [
    {
      "dayNumber": 1,
      "date": "2023-12-01",
      "title": "Day 1 Activities",
      "activities": [
        {
          "time": "09:00 AM",
          "title": "Activity Title",
          "description": "Detailed description of the activity",
          "category": "sightseeing",
          "location": "Specific place name",
          "latitude": 12.345678,
          "longitude": 98.765432,
          "durationMinutes": 120,
          "cost": 500.00
        }
      ]
    }
  ],
  "recommendations": [
    {
      "name": "Place Name",
      "category": "attraction",
      "description": "Brief description",
      "address": "Full address",
      "latitude": 12.345678,
      "longitude": 98.765432,
      "rating": 4.5,
      "averageCost": 1000.00,
      "imageUrl": "https://example.com/image.jpg"
    }
  ],
  "estimatedBudget": {
    "totalEstimatedCost": 15000.00,
    "perPersonCost": 7500.00,
    "costBreakdown": {
      "accommodation": 5000.00,
      "food": 3000.00,
      "transportation": 2000.00,
      "activities": 3000.00,
      "shopping": 1000.00,
      "miscellaneous": 1000.00
    }
  },
  "travelTips": [
    {
      "title": "Travel Tip Title",
      "description": "Detailed travel tip description"
    }
  ]
}

Generate a concise but comprehensive response:
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
      'temperature': 0.7,
      'maxOutputTokens': 3000, // Reduced for free account efficiency
      'topK': 40,
      'topP': 0.95,
    },
    'safetySettings': [
      {
        'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
        'threshold': 'BLOCK_ONLY_HIGH'
      }
    ]
  };

  try {
    print('Calling Gemini API...');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    ).timeout(Duration(seconds: 45));

    print('Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('API Response received successfully');
      
      // Check if response has the expected structure
      if (jsonResponse['candidates'] == null || jsonResponse['candidates'].isEmpty) {
        print('Error: No candidates found in response');
        return;
      }
      
      // Extract the generated text from the response
      final candidates = jsonResponse['candidates'];
      if (candidates == null || candidates.isEmpty) {
        print('Error: Empty candidates');
        return;
      }
      
      final content = candidates[0]['content'];
      if (content == null) {
        print('Error: Missing content');
        return;
      }
      
      final parts = content['parts'];
      if (parts == null || parts.isEmpty) {
        print('Error: Missing parts');
        return;
      }
      
      final generatedText = parts[0]['text'];
      if (generatedText == null || generatedText.isEmpty) {
        print('Error: Empty generated text');
        return;
      }
      
      print('Generated text length: ${generatedText.length}');
      print('Generated text (first 2000 chars):');
      print(generatedText.substring(0, generatedText.length > 2000 ? 2000 : generatedText.length));
      if (generatedText.length > 2000) {
        print('... (text truncated)');
      }
      
      // Try to parse as JSON
      try {
        // First try to extract JSON from code blocks
        final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
        final codeBlockMatch = codeBlockRegex.firstMatch(generatedText);
        
        String jsonString;
        if (codeBlockMatch != null) {
          jsonString = codeBlockMatch.group(1)?.trim() ?? generatedText.trim();
        } else {
          // If no code blocks found, try to find JSON between curly braces
          final jsonRegex = RegExp(r'\{[\s\S]*\}');
          final jsonMatch = jsonRegex.firstMatch(generatedText);
          
          if (jsonMatch != null) {
            jsonString = jsonMatch.group(0)?.trim() ?? generatedText.trim();
          } else {
            jsonString = generatedText.trim();
          }
        }
        
        print('Attempting to parse JSON:');
        print(jsonString);
        
        final jsonData = jsonDecode(jsonString);
        print('JSON parsed successfully!');
        print('Parsed data keys: ${jsonData.keys.toList()}');
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      print('Error response: ${response.body}');
    }
  } catch (e) {
    print('Error calling API: $e');
  }
}