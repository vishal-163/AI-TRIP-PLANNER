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

  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';
  
  final prompt = '''
Generate a minimal JSON response:
{
  "test": "success"
}
Return only the JSON, nothing else.
''';

  try {
    final httpClient = HttpClient();
    final request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({
      'contents': [{
        'parts': [{'text': prompt}]
      }],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1000,
      }
    });
    
    request.write(body);
    final response = await request.close();
    
    print('Status code: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('Response body: $responseBody');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('API call successful');
      print('Data: $data');
    } else {
      print('API call failed');
    }
    
    httpClient.close();
  } catch (e) {
    print('Error: $e');
  }
}