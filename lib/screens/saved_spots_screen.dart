import 'package:flutter/material.dart';

class SavedSpotsScreen extends StatefulWidget {
  const SavedSpotsScreen({super.key});

  @override
  State<SavedSpotsScreen> createState() => _SavedSpotsScreenState();
}

class _SavedSpotsScreenState extends State<SavedSpotsScreen> {
  final List<Map<String, dynamic>> savedSpots = [
    {'name': 'Park', 'db': 39, 'status': 'Usually Quiet', 'isFavorite': true, 'isEnabled': true},
    {'name': 'Library', 'db': 34, 'status': 'Very Quiet', 'isFavorite': false, 'isEnabled': false},
    {'name': 'Office', 'db': 41, 'status': 'Usually Quiet', 'isFavorite': false, 'isEnabled': false},
    {'name': 'Café', 'db': 44, 'status': 'Quieter Than Normal', 'isFavorite': false, 'isEnabled': false},
  ];

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your favorite quiet places",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: savedSpots.length,
                itemBuilder: (context, index) {
                  final spot = savedSpots[index];
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
                        // Name and Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spot['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${spot['db']} dB   ${spot['status']}",
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),

                        // Toggle + Star
                        Row(
                          children: [
                            // Switch Toggle
                            Switch(
                              value: spot['isEnabled'],
                              onChanged: (value) {
                                setState(() {
                                  savedSpots[index]['isEnabled'] = value;
                                });
                              },
                              activeColor: Colors.white,
                            ),
                            const SizedBox(width: 8),

                            // Star Icon Toggle
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  savedSpots[index]['isFavorite'] =
                                      !savedSpots[index]['isFavorite'];
                                });
                              },
                              child: Icon(
                                spot['isFavorite'] ? Icons.star : Icons.star_border,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
