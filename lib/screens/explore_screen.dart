import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart'; // Ensure this exists
import 'filter_screen.dart';
import 'saved_spots_screen.dart';
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
              // Title + Top Buttons
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
                        onPressed: () {
                          Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const FilterScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F7056),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        child: const Text("Filter"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SavedSpotsScreen()),
               );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F7056),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        child: const Text("List View"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                "Tap a location to view sound level",
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
                      // Map Markers
                      _buildMarker(left: 40, top: 60, isQuiet: true),
                      _buildMarker(left: 100, top: 120, isQuiet: false),
                      _buildMarker(left: 160, top: 220, isQuiet: true),
                      _buildMarker(left: 230, top: 90, isQuiet: false),
                      _buildMarker(left: 280, top: 160, isQuiet: true),

                      // Tooltip
                      Positioned(
                        left: 100,
                        top: 170,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F5A45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Library",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "38 dB",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Zoom and center buttons
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

  // Location Marker
  Widget _buildMarker({required double left, required double top, required bool isQuiet}) {
    return Positioned(
      left: left,
      top: top,
      child: Icon(
        Icons.location_on,
        color: isQuiet ? Colors.greenAccent : Colors.redAccent,
        size: 30,
      ),
    );
  }

  // Round Buttons
  Widget _mapControlButton(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF3F7056),
      child: Icon(icon, color: Colors.white),
    );
  }
}

