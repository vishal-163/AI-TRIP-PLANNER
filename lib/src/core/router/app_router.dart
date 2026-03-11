import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Screens
import '../../features/trip_generation/presentation/screens/trip_input_screen.dart';
import '../../features/trip_generation/presentation/screens/itinerary_screen.dart';
import '../../features/map_view/presentation/screens/map_screen.dart';
import '../../features/expenses/presentation/screens/expense_dashboard_screen.dart';
import '../../features/expenses/presentation/screens/add_expense_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/trips/presentation/screens/saved_trips_screen.dart';
import '../../features/trips/presentation/screens/saved_trip_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = 'onboarding'; // Removed leading slash
  static const String tripInput = '/trip-input';
  static const String itinerary = '/itinerary';
  static const String map = '/map';
  static const String expenseDashboard = '/expenses';
  static const String addExpense = '/add-expense';
  static const String settings = '/settings';
  static const String savedTrips = '/saved-trips';
  static const String savedTripDetail = '/saved-trip-detail';

  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
        routes: [
          GoRoute(
            path: onboarding, // This will now be '/onboarding' relative to splash
            builder: (BuildContext context, GoRouterState state) {
              return const OnboardingScreen();
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return child;
        },
        routes: [
          GoRoute(
            path: login,
            builder: (BuildContext context, GoRouterState state) {
              return const LoginScreen();
            },
          ),
          GoRoute(
            path: tripInput,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TripInputScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Custom slide transition
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;
                
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: itinerary,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ItineraryScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Fade and scale transition
                const begin = 0.0;
                const end = 1.0;
                const curve = Curves.easeOutBack;
                
                var opacityTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var scaleTween = Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));
                
                var opacityAnimation = animation.drive(opacityTween);
                var scaleAnimation = animation.drive(scaleTween);
                
                return FadeTransition(
                  opacity: opacityAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: map,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MapScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Custom slide from bottom
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;
                
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          ),
            GoRoute(
              path: expenseDashboard,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ExpenseDashboardScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // Modern slide up and fade transition
                  const begin = Offset(0.0, 0.1);
                  const end = Offset.zero;
                  const curve = Curves.easeOutCirc;
                  
                  var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                  
                  var slideAnimation = animation.drive(slideTween);
                  var fadeAnimation = animation.drive(fadeTween);
                  
                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: child,
                    ),
                  );
                },
              ),
            ),
          GoRoute(
            path: addExpense,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: AddExpenseScreen(expenseId: state.extra as String?),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Slide from right with fade
                const beginOffset = Offset(1.0, 0.0);
                const endOffset = Offset.zero;
                const beginOpacity = 0.0;
                const endOpacity = 1.0;
                
                var offsetTween = Tween(begin: beginOffset, end: endOffset);
                var opacityTween = Tween(begin: beginOpacity, end: endOpacity);
                
                var offsetAnimation = animation.drive(offsetTween);
                var opacityAnimation = animation.drive(opacityTween);
                
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: opacityAnimation,
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Zoom in transition
                var scaleTween = Tween(begin: 0.0, end: 1.0);
                var scaleAnimation = animation.drive(scaleTween);
                
                return ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: savedTrips,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SavedTripsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Slide from left
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;
                
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '$savedTripDetail/:tripId',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: SavedTripDetailScreen(tripId: state.pathParameters['tripId']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Bounce transition
                const curve = Curves.elasticOut;
                var scaleTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                var scaleAnimation = animation.drive(scaleTween);
                
                return ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    ],
  );
}