import 'package:flutter/material.dart';
import 'place_data.dart';
import 'place_model.dart';

class SavedSpotsScreen extends StatefulWidget {
  const SavedSpotsScreen({super.key});

  @override
  State<SavedSpotsScreen> createState() => _SavedSpotsScreenState();
}

class _SavedSpotsScreenState extends State<SavedSpotsScreen> {
  @override
  Widget build(BuildContext context) {
    final savedPlaces = allPlaces.where((p) => p.isSaved).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF6E9C84),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E9C84),
        title: const Text(
          "My Saved Spots",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: savedPlaces.isEmpty
            ? const Center(
                child: Text(
                  "No saved places yet 😴",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: savedPlaces.length,
                itemBuilder: (context, index) {
                  final place = savedPlaces[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F7056),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Place name + info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${place.db} dB   ${place.type}",
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),

                        // Toggle save
                        IconButton(
                          icon: Icon(
                            place.isSaved ? Icons.star : Icons.star_border,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              place.isSaved = !place.isSaved;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
