import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/repositories/trip_database_repository.dart';

class SavedTripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  
  const SavedTripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<SavedTripDetailScreen> createState() => _SavedTripDetailScreenState();
}

class _SavedTripDetailScreenState extends ConsumerState<SavedTripDetailScreen> {
  late Future<Map<String, dynamic>?> _tripFuture;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  void _loadTrip() {
    setState(() {
      _tripFuture = ref.read(tripDatabaseRepositoryProvider).getFullTripById(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _tripFuture,
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
                  const Text('Failed to load trip details'),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTrip,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No trip data found'),
            );
          }

          final tripData = snapshot.data!;
          final trip = tripData['trip'];
          final dailyItinerary = tripData['daily_itinerary'] as List;
          final recommendations = tripData['recommendations'] as List;
          final budgetEstimate = tripData['budget_estimate'];
          final travelTips = tripData['travel_tips'] as List;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Summary Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['trip_title'] ?? 'Untitled Trip',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${trip['origin'] ?? 'Unknown'} → ${(trip['destinations'] is List) ? (trip['destinations'] as List).join(', ') : (trip['destinations'] as String?) ?? 'Unknown'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('MMM dd, yyyy').format(DateTime.parse(trip['start_date']))} - ${DateFormat('MMM dd, yyyy').format(DateTime.parse(trip['end_date']))}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${trip['number_of_travelers'] ?? 1} Traveler${(trip['number_of_travelers'] ?? 1) > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (trip['interests'] as List).map((interest) {
                              return Chip(
                                label: Text(interest.toString()),
                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Estimated Budget
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Budget',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Cost:'),
                              Text(
                                '₹${(budgetEstimate['total_estimated_cost'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Per Person:'),
                              Text(
                                '₹${(budgetEstimate['per_person_cost'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Cost Breakdown:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...(budgetEstimate['cost_breakdown'] is Map
                              ? (budgetEstimate['cost_breakdown'] as Map).entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            entry.key.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        Text(
                                          '₹${(entry.value as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                              : []),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Daily Itinerary
                  const Text(
                    'Daily Itinerary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dailyItinerary.map((day) {
                    final activities = day['activities'] as List;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day ${day['day_number']}: ${day['title']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMM dd, yyyy').format(DateTime.parse(day['date'])),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            ...activities.map((activity) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 70,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        activity['time'].toString(),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity['title'].toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            activity['description'].toString(),
                                            style: Theme.of(context).textTheme.bodyMedium,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Theme.of(context).disabledColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  activity['location'].toString(),
                                                  style: TextStyle(
                                                    color: Theme.of(context).disabledColor,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (activity['cost'] != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.attach_money,
                                                  size: 16,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '₹${(activity['cost'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                                  style: TextStyle(
                                                    color: Theme.of(context).disabledColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Recommendations
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recommendations.map((recommendation) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    recommendation['category'] == 'Accommodation'
                                        ? Icons.hotel
                                        : recommendation['category'] == 'Food'
                                            ? Icons.restaurant
                                            : recommendation['category'] == 'Attraction'
                                                ? Icons.attractions
                                                : Icons.place,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recommendation['name'].toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        recommendation['category'].toString(),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              recommendation['description'].toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Theme.of(context).disabledColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    recommendation['address'].toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).disabledColor,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (recommendation['rating'] != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (recommendation['rating'] as num?)?.toString() ?? '',
                                    style: TextStyle(
                                      color: Theme.of(context).disabledColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (recommendation['average_cost'] != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 16,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Avg. ₹${(recommendation['average_cost'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(
                                      color: Theme.of(context).disabledColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Travel Tips
                  const Text(
                    'Travel Tips',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...travelTips.map((tip) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip['title'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip['description'].toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}