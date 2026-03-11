import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const apiKey = 'AIzaSyCIA61-UNFNyN3jASZjTLS1RQ5BQHoVYv8';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey';

  print('Querying: $url');
  try {
    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['models'] != null) {
        print('--- AVAILABLE MODELS ---');
        for (var model in data['models']) {
          print(model['name']);
        }
        print('------------------------');
      } else {
        print('No models found in JSON response.');
      }
    } else {
      print('Error body: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
