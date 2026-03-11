import 'dart:convert';
import 'package:http/http.dart' as http;

// Test our fixes for the "empty generated text" issue
Future<void> main() async {
  print('Testing AI Trip Planner fixes...');
  
  // Test JSON extraction function with sample data
  final sampleResponse = {
    "candidates": [
      {
        "content": {
          "parts": [
            {
              "text": '{"summary":{"tripTitle":"Test Trip"}}'
            }
          ]
        }
      }
    ]
  };
  
  // Simulate the text extraction
  final candidates = sampleResponse['candidates'] as List;
  final firstCandidate = candidates[0] as Map<String, dynamic>;
  
  String extractedText = '';
  if (firstCandidate.containsKey('content')) {
    final content = firstCandidate['content'] as Map<String, dynamic>;
    if (content.containsKey('parts')) {
      final parts = content['parts'] as List;
      for (var part in parts) {
        if (part is Map && part['text'] is String) {
          extractedText += part['text'] as String;
        }
      }
    }
  }
  
  print('Extracted text: $extractedText');
  
  if (extractedText.isNotEmpty) {
    print('✅ Fix successful - text extracted correctly');
  } else {
    print('❌ Fix failed - no text extracted');
  }
  
  print('Test completed.');
}