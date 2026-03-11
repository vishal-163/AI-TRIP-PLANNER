import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/trip_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/router/app_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'AI Service',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ListTile(
              title: Text('Gemini'),
              subtitle: Text('Using Google\'s Gemini AI for itinerary generation'),
              trailing: Icon(Icons.check, color: Colors.green),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: const Text('AI Trip Planner'),
              subtitle: const Text(
                'Plan your perfect journey with AI. This app uses Gemini AI or OpenRouter to generate personalized travel itineraries based on your preferences and constraints. © 2025 AI Trip Planner. All rights reserved.',
                maxLines: 3,
              ),
              onTap: () {
                HapticFeedback.mediumImpact();
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('AI Trip Planner'),
                    content: const Text(
                      'Plan your perfect journey with AI.\n\n'
                      'This app uses Gemini AI or OpenRouter to generate personalized travel itineraries '
                      'based on your preferences and constraints.\n\n'
                      '© 2025 AI Trip Planner. All rights reserved.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: const Text('Privacy Policy'),
              onTap: () {
                HapticFeedback.mediumImpact();
                
                // In a real app, this would open a web view with the privacy policy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy would be shown here'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: const Text('Terms of Service'),
              onTap: () {
                HapticFeedback.mediumImpact();
                
                // In a real app, this would open a web view with the terms of service
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms of Service would be shown here'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Logout button
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () async {
                HapticFeedback.mediumImpact();
                
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                
                // If user confirmed logout
                if (shouldLogout == true) {
                  try {
                    // Sign out from Supabase
                    final supabase = ref.read(supabaseProvider);
                    await supabase.auth.signOut();
                    
                    // Navigate to login screen
                    if (context.mounted) {
                      context.go(AppRouter.login);
                    }
                  } catch (e) {
                    // Show error message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error logging out: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}