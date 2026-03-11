import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://cizfpaaybfydvotwvbku.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpemZwYWF5YmZ5ZHZvdHd2Ymt1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1OTY2MTUsImV4cCI6MjA3ODE3MjYxNX0.SG33hxj0LUDg8r22ycsRXDwLJwbebDIoWSuLKNiDSys',
  );
  
  // Handle deep links
  await _handleDeepLinks();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _handleDeepLinks() async {
  // Handle incoming links
  try {
    // Handle initial link if app is launched from a link
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleLink(initialLink);
    }
    
    // Listen for incoming links while app is running
    linkStream.listen((link) {
      if (link != null) {
        _handleLink(link);
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  } catch (e) {
    print('Error handling deep links: $e');
  }
}

void _handleLink(String link) {
  print('Received deep link: $link');
  // Handle Supabase auth links
  if (link.contains('supabase.co/auth/v1/verify')) {
    // The Supabase auth will be handled automatically by the Supabase SDK
    print('Processing Supabase auth link');
  }
  // Add other link handling logic here if needed
}