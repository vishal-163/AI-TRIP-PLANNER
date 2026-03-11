import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('.env');
  final lines = await file.readAsLines();
  String apiKey = '';
  
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }
  
  if (apiKey.isEmpty) {
    print('GEMINI_API_KEY not found in .env file');
    return;
  }

  final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey';

  try {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    
    print('Status code: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('Response body: $responseBody');
    
    httpClient.close();
  } catch (e) {
    print('Error: $e');
  }
}