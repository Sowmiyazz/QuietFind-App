import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Set<Marker> _markers = {};
  bool isLoading = true;
  GoogleMapController? _mapController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const LatLng defaultLocation = LatLng(9.9252, 78.1198); // Madurai

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  /// Load places from Firestore and set markers
  Future<void> _loadPlaces() async {
    try {
      final snapshot = await _firestore.collection('places').get();
      final savedSnapshot = await _firestore.collection('saved_spots').get();
      final savedNames = savedSnapshot.docs.map((doc) => doc['name']).toSet();

      final List<Place> places = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Place(
          name: data['name'] ?? '',
          db: (data['db'] is num) ? (data['db'] as num).toDouble() : 0.0,
          type: data['type'] ?? '',
          isQuiet: data['isQuiet'] ?? true,
          isSaved: savedNames.contains(data['name']),
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
        );
      }).toList();

      setState(() {
        displayedPlaces = places;
        _markers = places.map((place) => _createMarker(place)).toSet();
        isLoading = false;
      });

    } catch (e) {
      print("❌ Error fetching places: $e");
      setState(() => isLoading = false);
    }
  }

  /// Toggle saving a place
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

      // Update markers when state changes
      setState(() {
        _markers = displayedPlaces.map((p) => _createMarker(p)).toSet();
      });
    } catch (e) {
      print("⚠️ Error saving/removing spot: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating saved spot')),
      );
    }
  }

  /// Create a marker for each place
  Marker _createMarker(Place place) {
    return Marker(
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
        snippet: "${place.db.toStringAsFixed(1)} dB - ${place.type}",
        onTap: () => _toggleSavePlace(place),
      ),
    );
  }

  /// Open FilterScreen and receive result
  Future<void> _openFilterScreen() async {
    final filtered = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterScreen()),
    );

    if (filtered != null && filtered is List<Place>) {
      setState(() {
        displayedPlaces = filtered;
        _markers = filtered.map((p) => _createMarker(p)).toSet();
      });
    } else {
      _loadPlaces();
    }
  }

  /// Center on a default or current location
  void _centerMap() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(defaultLocation, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E9C84),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _openFilterScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F7056),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("List View"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Text(
                "Tap a marker to save or remove spot",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                            _centerMap();
                          },
                          initialCameraPosition: const CameraPosition(
                            target: defaultLocation,
                            zoom: 14,
                          ),
                          markers: _markers,
                          zoomControlsEnabled: true,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
