import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/repositories/trip_database_repository.dart';

class SavedTripsScreen extends ConsumerStatefulWidget {
  const SavedTripsScreen({super.key});

  @override
  ConsumerState<SavedTripsScreen> createState() => _SavedTripsScreenState();
}

class _SavedTripsScreenState extends ConsumerState<SavedTripsScreen> with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _tripsFuture;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    
    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );
    
    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerController.forward();
    });
    
    _loadTrips();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _loadTrips() {
    setState(() {
      // Initialize the database first, then get trips
      _tripsFuture = _initializeAndLoadTrips();
    });
  }

  Future<List<Map<String, dynamic>>> _initializeAndLoadTrips() async {
    try {
      final databaseRepository = ref.read(tripDatabaseRepositoryProvider);
      await databaseRepository.initializeDatabase();
      return await databaseRepository.getAllTrips();
    } catch (e) {
      // If initialization fails, try to get trips directly
      return await ref.read(tripDatabaseRepositoryProvider).getAllTrips();
    }
  }

  void _deleteTrip(String tripId) {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip?'),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              
              try {
                await ref.read(tripDatabaseRepositoryProvider).deleteTrip(tripId);
                _loadTrips(); // Refresh the list
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trip deleted successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete trip')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizeTransition(
          sizeFactor: _headerAnimation,
          child: const Text('Saved Trips'),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load trips'),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTrips,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final trips = snapshot.data ?? [];
          
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved trips yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate a trip to see it here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    trip['trip_title'] ?? 'Untitled Trip',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Origin: ${trip['origin'] ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Destinations: ${(trip['destinations'] is List) ? (trip['destinations'] as List).join(', ') : (trip['destinations'] as String?) ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Travelers: ${trip['number_of_travelers'] ?? 1}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${(trip['created_at'] as String?)?.split('T').first ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTrip(trip['id'].toString()),
                    splashRadius: 24,
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    // Navigate to trip details screen
                    context.push('/saved-trip-detail/${trip['id']}');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}