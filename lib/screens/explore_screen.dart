import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'bottom_nav_bar.dart';
import 'filter_screen.dart';
import 'saved_spots_screen.dart';
import 'place_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Place> displayedPlaces = [];
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GoogleMapController _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
    _loadCurrentLocation();
    _loadPlaces();
  }

  /// Load all places from Firestore and create map markers
  Future<void> _loadPlaces() async {
    try {
      final snapshot = await _firestore.collection('places').get();

      setState(() {
        displayedPlaces = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Place(
            name: data['name'] ?? '',
            db: (data['db'] as num?)?.toDouble() ?? 0.0,
            type: data['type'] ?? '',
            isQuiet: data['isQuiet'] ?? true,
            isSaved: data['isSaved'] ?? false,
            latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        _markers.clear();
        for (var place in displayedPlaces) {
          if (place.latitude != 0.0 && place.longitude != 0.0) {
            _markers.add(
              Marker(
                markerId: MarkerId(place.name),
                position: LatLng(place.latitude, place.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  place.isSaved
                      ? BitmapDescriptor.hueYellow
                      : (place.isQuiet
                          ? BitmapDescriptor.hueGreen
                          : BitmapDescriptor.hueRed),
                ),
                infoWindow: InfoWindow(
                  title: place.name,
                  snippet: '${place.type} • ${place.db.toStringAsFixed(1)} dB',
                  onTap: () => _toggleSavePlace(place),
                ),
              ),
            );
          }
        }

        isLoading = false;
      });
      print("✅ Places loaded: ${displayedPlaces.length}");
    } catch (e) {
      print("❌ Error fetching places: $e");
      setState(() => isLoading = false);
    }
  }

  /// Toggle saving a place to saved_spots collection
  Future<void> _toggleSavePlace(Place place) async {
    try {
      setState(() {
        place.isSaved = !place.isSaved;
      });

      if (place.isSaved) {
        await _firestore.collection('saved_spots').add({
          'name': place.name,
          'db': place.db,
          'type': place.type,
          'isQuiet': place.isQuiet,
          'latitude': place.latitude,
          'longitude': place.longitude,
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${place.name} saved!')));
      } else {
        final query = await _firestore
            .collection('saved_spots')
            .where('name', isEqualTo: place.name)
            .get();

        for (var doc in query.docs) {
          await _firestore.collection('saved_spots').doc(doc.id).delete();
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${place.name} removed!')));
      }

      // Update markers with new saved state
      _loadPlaces();
    } catch (e) {
      print("⚠️ Error saving/removing spot: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating saved spot')),
      );
    }
  }

  /// Handle location permissions
  Future<void> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  /// Load current user location
  Future<void> _loadCurrentLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {});
  }

  /// Center map on current location
  void _goToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E9C84),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: isLoading || _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Header with filter and list view
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quiet Places Map",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FilterScreen()),
                                );
                                _loadPlaces();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F7056),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Filter"),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SavedSpotsScreen()),
                                ).then((_) => _loadPlaces());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F7056),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("List View"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Google Map
                  Expanded(
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            zoom: 14,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          markers: _markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        ),

                        // Map buttons
                        Positioned(
                          bottom: 20,
                          right: 16,
                          child: Column(
                            children: [
                              _mapControlButton(Icons.add, () {
                                _mapController.animateCamera(
                                  CameraUpdate.zoomIn(),
                                );
                              }),
                              const SizedBox(height: 8),
                              _mapControlButton(Icons.remove, () {
                                _mapController.animateCamera(
                                  CameraUpdate.zoomOut(),
                                );
                              }),
                              const SizedBox(height: 8),
                              _mapControlButton(Icons.my_location, () {
                                _goToCurrentLocation();
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _mapControlButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF3F7056),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
