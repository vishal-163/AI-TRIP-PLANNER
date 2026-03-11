import 'package:flutter/material.dart';
import 'package:ai_trip_planner/src/core/services/gemini_service.dart';
import 'package:ai_trip_planner/src/core/services/openrouter_service.dart';
import 'package:ai_trip_planner/src/core/models/trip_input_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Services Test',
      home: TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _result = 'Click buttons to test services';
  bool _isLoading = false;

  final tripInput = TripInputModel(
    origin: 'New York',
    destinations: ['Paris'],
    startDate: DateTime(2024, 6, 1),
    endDate: DateTime(2024, 6, 5),
    numberOfTravelers: 2,
    interests: ['Art', 'Food', 'History'],
    budgetLevel: 'Mid-range',
    specialConstraints: 'None',
  );

  void _testGeminiService() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing Gemini service...';
    });

    try {
      final itinerary = await GeminiService.generateItinerary(tripInput);
      setState(() {
        _result = 'Gemini Success!\n'
            'Title: ${itinerary.summary.tripTitle}\n'
            'Days: ${itinerary.dailyItinerary.length}\n'
            'Recommendations: ${itinerary.recommendations.length}\n'
            'Travel Tips: ${itinerary.travelTips?.length ?? 0}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Gemini Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Service Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGeminiService,
              child: const Text('Test Gemini Service'),
            ),
            const SizedBox(height: 10),
            // Remove the OpenRouter test button
          ],
        ),
      ),
    );
  }
}