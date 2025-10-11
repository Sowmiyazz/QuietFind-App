import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  /// 🧩 Load all places from Firestore
  Future<void> _loadPlaces() async {
    try {
      final snapshot = await _firestore.collection('places').get();

      setState(() {
        displayedPlaces = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Place(
            name: data['name'] ?? '',
            db: (data['db'] is num) ? (data['db'] as num).toDouble() : 0.0,
            type: data['type'] ?? '',
            isQuiet: data['isQuiet'] ?? true,
            isSaved: data['isSaved'] ?? false,
          );
        }).toList();
        isLoading = false;
      });
      print("✅ Places loaded: ${displayedPlaces.length}");
    } catch (e) {
      print("❌ Error fetching places: $e");
      setState(() => isLoading = false);
    }
  }

  /// ⭐ Toggle saving a place
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
    } catch (e) {
      print("⚠️ Error saving/removing spot: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating saved spot')),
      );
    }
  }

  /// 🔍 Open FilterScreen and receive results
  Future<void> _openFilterScreen() async {
    final filtered = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterScreen()),
    );

    // If results came from FilterScreen
    if (filtered != null && filtered is List<Place>) {
      setState(() {
        displayedPlaces = filtered;
      });
    } else {
      // If no filters applied or cleared → reload all
      _loadPlaces();
    }
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
                "Tap a location to view or save spot",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : displayedPlaces.isEmpty
                        ? const Center(
                            child: Text(
                              "No places found 😕",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 18),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D856F),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                // Markers
                                ...displayedPlaces.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Place place = entry.value;

                                  double left = 40.0 + (index * 50);
                                  double top = 60.0 + (index * 70);

                                  return _buildMarker(
                                    left: left,
                                    top: top,
                                    isQuiet: place.isQuiet,
                                    label:
                                        "${place.name} (${place.db.toStringAsFixed(1)} dB)",
                                    isSaved: place.isSaved,
                                    onToggleSave: () =>
                                        _toggleSavePlace(place),
                                  );
                                }).toList(),

                                // Map control buttons
                                Positioned(
                                  bottom: 20,
                                  right: 16,
                                  child: Column(
                                    children: [
                                      _mapControlButton(Icons.add),
                                      const SizedBox(height: 8),
                                      _mapControlButton(Icons.remove),
                                      const SizedBox(height: 8),
                                      _mapControlButton(Icons.my_location),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarker({
    required double left,
    required double top,
    required bool isQuiet,
    required String label,
    required bool isSaved,
    required VoidCallback onToggleSave,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggleSave,
            child: Icon(
              isSaved ? Icons.star : Icons.location_on,
              color: isSaved
                  ? Colors.yellowAccent
                  : (isQuiet ? Colors.greenAccent : Colors.redAccent),
              size: 32,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _mapControlButton(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF3F7056),
      child: Icon(icon, color: Colors.white),
    );
  }
}
