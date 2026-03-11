import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/supabase_provider.dart';
import '../../core/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check authentication state
    final authState = ref.read(authStateProvider);
    
    authState.when(
      data: (state) {
        if (state.session != null) {
          // User is authenticated, go to main app
          context.go(AppRouter.tripInput);
        } else {
          // User is not authenticated, go to login
          context.go(AppRouter.login);
        }
      },
      loading: () {
        // Still loading auth state, go to login as fallback
        context.go(AppRouter.login);
      },
      error: (error, stack) {
        // Error with auth, go to login
        context.go(AppRouter.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF21CBF3),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airplanemode_active,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'AI Trip Planner',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Plan your perfect journey with AI',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}