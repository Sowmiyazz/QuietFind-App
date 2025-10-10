import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'filter_screen.dart';
import 'saved_spots_screen.dart';
import 'place_data.dart';
import 'place_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Place> displayedPlaces = List.from(allPlaces); // Initially show all

  Future<void> _openFilterScreen() async {
    final filtered = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterScreen()),
    );

    if (filtered != null && filtered is List<Place>) {
      setState(() {
        displayedPlaces = filtered;
      });
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
              // Header row
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            MaterialPageRoute(builder: (context) => const SavedSpotsScreen()),
                          ).then((_) => setState(() {})); // Refresh after returning
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F7056),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              // Map section
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D856F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Dynamic markers
                      ...displayedPlaces.asMap().entries.map((entry) {
                        int index = entry.key;
                        Place place = entry.value;

                        double left = 40.0 + (index * 50);
                        double top = 60.0 + (index * 70);

                        return _buildMarker(
                          left: left,
                          top: top,
                          isQuiet: place.isQuiet,
                          label: "${place.name} (${place.db} dB)",
                          isSaved: place.isSaved,
                          onToggleSave: () {
                            setState(() {
                              place.isSaved = !place.isSaved;
                            });
                          },
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
