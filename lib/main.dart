import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://cizfpaaybfydvotwvbku.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpemZwYWF5YmZ5ZHZvdHd2Ymt1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1OTY2MTUsImV4cCI6MjA3ODE3MjYxNX0.SG33hxj0LUDg8r22ycsRXDwLJwbebDIoWSuLKNiDSys',
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}