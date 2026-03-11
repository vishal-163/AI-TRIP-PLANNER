import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/itinerary_model.dart';
import '../../../../core/models/trip_input_model.dart';
import '../../../../core/providers/trip_provider.dart';
import '../../../../core/repositories/trip_database_repository.dart' as db_repo;
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/bouncing_button.dart';

class ItineraryScreen extends ConsumerWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (state) {
        if (state.session != null) {
          return const _ItineraryScreenContent();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRouter.login);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRouter.login);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _ItineraryScreenContent extends ConsumerWidget {
  const _ItineraryScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripInput = ref.watch(tripInputProvider);
    final refresh = ref.watch(refreshItineraryProvider);
    final itineraryAsync = ref.watch(generateItineraryProvider(tripInput ?? TripInputModel(
      origin: '',
      destinations: [],
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      numberOfTravelers: 1,
      budgetLevel: '',
      interests: [],
      specialConstraints: '',
    )));

    return GradientScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(generateItineraryProvider(tripInput!));
        },
        child: itineraryAsync.when(
          skipLoadingOnRefresh: false,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text('Failed to generate itinerary', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ModernButton(
                  onPressed: () => ref.invalidate(generateItineraryProvider(tripInput!)),
                  text: 'Try Again',
                  icon: Icons.refresh,
                ),
              ],
            ),
          ),
          data: (itinerary) => Stack(
            children: [
              ItineraryView(itinerary: itinerary),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomDock(context, ref, itinerary, tripInput!),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black87),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Your Journey',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: IconButton(
                            icon: const Icon(Icons.folder_open, color: Colors.black87),
                            onPressed: () => context.push('/saved-trips'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBottomDock(BuildContext context, WidgetRef ref, ItineraryModel itinerary, TripInputModel tripInput) {
    return GlassContainer(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDockItem(context, Icons.save_outlined, 'Save', () async {
            try {
              final databaseRepository = ref.read(db_repo.tripDatabaseRepositoryProvider);
              await databaseRepository.initializeDatabase();
              await databaseRepository.saveTrip(itinerary, tripInput);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trip saved successfully!')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save trip: $e')),
                );
              }
            }
          }),
          _buildDockItem(context, Icons.map_outlined, 'Map', () => context.push('/map')),
          _buildDockItem(context, Icons.account_balance_wallet_outlined, 'Expenses', () => context.push('/expenses')),
          _buildDockItem(context, Icons.picture_as_pdf_outlined, 'PDF', () async {
            try {
              final pdfPath = await PdfService.generateItineraryReport(itinerary);
              final file = XFile(pdfPath);
              await Share.shareXFiles([file]);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error sharing PDF: $e')),
                );
              }
            }
          }),
          _buildDockItem(context, Icons.refresh, 'Refresh', () {
            // Invalidate the provider to trigger a rebuild and show loading state
            ref.invalidate(generateItineraryProvider(tripInput));
          }, isAnimating: ref.watch(generateItineraryProvider(tripInput)).isLoading),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildDockItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isAnimating = false}) {
    return BouncingButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24)
              .animate(target: isAnimating ? 1 : 0)
              .rotate(duration: 1000.ms, curve: Curves.easeInOut),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ItineraryView extends StatelessWidget {
  final ItineraryModel itinerary;

  const ItineraryView({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 100), // Adjust padding for top bar and bottom dock
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context).animate().fadeIn().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          _buildBudgetCard(context).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 32),
          Text('Your Timeline', style: Theme.of(context).textTheme.displayMedium)
              .animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          ...itinerary.dailyItinerary.asMap().entries.map((entry) {
            return _buildTimelineDay(context, entry.value, entry.key, entry.key == itinerary.dailyItinerary.length - 1);
          }),
          const SizedBox(height: 32),
          Text('Recommendations', style: Theme.of(context).textTheme.displayMedium)
              .animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              cacheExtent: 500,
              itemCount: itinerary.recommendations.length,
              itemBuilder: (context, index) {
                return _buildRecommendationCard(context, itinerary.recommendations[index], index);
              },
            ),
          ),
          const SizedBox(height: 32),
          Text('Travel Tips', style: Theme.of(context).textTheme.displayMedium)
              .animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 16),
          ...itinerary.travelTips?.map((tip) => _buildTipCard(context, tip)) ?? [],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itinerary.summary.tripTitle,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${itinerary.summary.origin} → ${itinerary.summary.destinations.join(', ')}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMM dd').format(itinerary.summary.startDate)} - ${DateFormat('MMM dd, yyyy').format(itinerary.summary.endDate)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: itinerary.summary.interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(interest, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Budget', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '₹${itinerary.estimatedBudget.totalEstimatedCost.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.attach_money, color: Theme.of(context).primaryColor, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDay(BuildContext context, ItineraryDay day, int index, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${day.dayNumber}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${day.dayNumber}: ${day.title}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    DateFormat('EEEE, MMM dd').format(day.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ...day.activities.map((activity) => _buildTimelineActivity(context, activity)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100))).slideX();
  }

  Widget _buildTimelineActivity(BuildContext context, Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Increased opacity for better readability
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60, // Fixed width for time
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.time,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  activity.category == 'Food' ? Icons.restaurant :
                  activity.category == 'Accommodation' ? Icons.hotel :
                  Icons.place,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87, // Dark text for readability
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: GoogleFonts.poppins(
                    color: Colors.black54, // Darker grey for readability
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Recommendation recommendation, int index) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(12), // Reduced padding for better fit
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                // Use Unsplash Source for dynamic images based on keywords
                'https://source.unsplash.com/800x600/?${Uri.encodeComponent(recommendation.category)},${Uri.encodeComponent(recommendation.name)}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to a category-specific icon if image fails
                  return Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          recommendation.category.toLowerCase().contains('food') ? Icons.restaurant :
                          recommendation.category.toLowerCase().contains('hotel') ? Icons.hotel :
                          Icons.place,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recommendation.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              recommendation.category,
              style: GoogleFonts.poppins(color: Theme.of(context).primaryColor, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                Text(' ${recommendation.rating ?? "N/A"}', style: GoogleFonts.poppins(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 600 + (index * 100))).slideX();
  }

  Widget _buildTipCard(BuildContext context, TravelTip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(tip.description, style: GoogleFonts.poppins()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}