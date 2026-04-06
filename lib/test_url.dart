import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final apiKey = 'AIzaSyAcx9MepqrdoWIbi-9aSDVEbsTW6F6j1Mk';
  final models = ['gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-pro'];
  
  for (final model in models) {
    print('\\nTesting URL for model: $model');
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
    
    final requestBody = {
      'contents': [
        {'parts': [{'text': 'Hello, are you working?'}]}
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error: ${response.body}');
      } else {
        final jsonResponse = jsonDecode(response.body);
        print('Success: ${jsonResponse['candidates'][0]['content']['parts'][0]['text']}');
      }
    } catch (e) {
      print('Exception: \$e');
    }
  }
}
