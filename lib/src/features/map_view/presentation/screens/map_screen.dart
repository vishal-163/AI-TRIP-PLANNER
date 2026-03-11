import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/itinerary_model.dart';
import '../../../../core/providers/trip_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/router/app_router.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (state) {
        if (state.session != null) {
          
          return const _MapScreenContent();
        } else {
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRouter.login);
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        // Error with auth, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRouter.login);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _MapScreenContent extends ConsumerStatefulWidget {
  const _MapScreenContent({super.key});

  @override
  ConsumerState<_MapScreenContent> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<_MapScreenContent> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = <Marker>{};
  
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMapData();
    });
  }

  void _loadMapData() {
    final itinerary = ref.read(itineraryProvider);
    if (itinerary != null) {
      _updateMarkers(itinerary);
      _fitMapToMarkers();
    }
  }

  void _updateMarkers(ItineraryModel itinerary) {
    final Set<Marker> newMarkers = <Marker>{};
    
    // Add markers for activities
    for (final day in itinerary.dailyItinerary) {
      for (final activity in day.activities) {
        if (activity.latitude != null && activity.longitude != null) {
          final markerId = MarkerId('activity_${day.dayNumber}_${activity.title}');
          final marker = Marker(
            markerId: markerId,
            position: LatLng(activity.latitude!, activity.longitude!),
            infoWindow: InfoWindow(
              title: activity.title,
              snippet: '${activity.category}\n${activity.description}',
            ),
            icon: _getMarkerIconForCategory(activity.category),
          );
          newMarkers.add(marker);
        }
      }
    }
    
    
    for (final recommendation in itinerary.recommendations) {
      if (recommendation.latitude != null && recommendation.longitude != null) {
        final markerId = MarkerId('recommendation_${recommendation.name}');
        final marker = Marker(
          markerId: markerId,
          position: LatLng(recommendation.latitude!, recommendation.longitude!),
          infoWindow: InfoWindow(
            title: recommendation.name,
            snippet: '${recommendation.category}\n${recommendation.description}',
          ),
          icon: _getMarkerIconForCategory(recommendation.category),
        );
        newMarkers.add(marker);
      }
    }
    
    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  BitmapDescriptor _getMarkerIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'accommodation':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'food':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'attraction':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _fitMapToMarkers() {
    if (_mapController == null || _markers.isEmpty) return;
    
    final bounds = _getBoundsFromMarkers(_markers);
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController?.animateCamera(cameraUpdate);
  }

  LatLngBounds _getBoundsFromMarkers(Set<Marker> markers) {
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;
    
    for (final marker in markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }
    
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itinerary = ref.watch(itineraryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: itinerary == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No itinerary data available'),
                ],
              ),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _loadMapData();
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fitMapToMarkers,
        child: const Icon(Icons.fit_screen),
      ),
    );
  }
}