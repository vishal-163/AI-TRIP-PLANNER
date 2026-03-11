import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Hardcoding the key here for the script since loading .env in a standalone script can be tricky without flutter setup
  // I will use the key I saw in the .env file earlier
  const apiKey = 'AIzaSyCIA61-UNFNyN3jASZjTLS1RQ5BQHoVYv8';
  
  final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey';

  print('Fetching available models...');
  try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Available Models:');
      if (data['models'] != null) {
        for (var model in data['models']) {
          print('- ${model['name']}');
          print('  Supported methods: ${model['supportedGenerationMethods']}');
        }
      } else {
        print('No models found in response.');
      }
    } else {
      print('Error: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
