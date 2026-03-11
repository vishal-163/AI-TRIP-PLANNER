import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  if (apiKey.isEmpty) {
    print('GEMINI_API_KEY not found in environment variables');
    return;
  }

  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';
  
  final prompt = '''
Generate a minimal JSON response for a trip to Paris:
{
  "test": "success"
}
Return only the JSON, nothing else.
''';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{'text': prompt}]
        }],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1000,
        }
      }),
    ).timeout(const Duration(seconds: 20));

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('API call successful');
      print('Data: $data');
    } else {
      print('API call failed');
    }
  } catch (e) {
    print('Error: $e');
  }
}