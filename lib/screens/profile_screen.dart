import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart'; // Import your bottom nav bar
import 'feedback_screen.dart'; // Feedback page

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _preferredDb = 40;
  final List<String> _tags = ['Reading', 'Meditation', 'Study'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E9C84),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E9C84),
        title: const Text(
          "MY PROFILE",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), // ✅ Add this
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF3F7056),
              child: Icon(Icons.person, size: 60, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              "username",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Preferred dB range",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            Slider(
              value: _preferredDb,
              min: 30,
              max: 50,
              divisions: 20,
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
              label: '${_preferredDb.round()}',
              onChanged: (value) {
                setState(() => _preferredDb = value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("30", style: TextStyle(color: Colors.white70)),
                Text("50", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: _tags.map((tag) {
                return Chip(
                  backgroundColor: const Color(0xFF3F7056),
                  label: Text(tag, style: const TextStyle(color: Colors.white)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              "12 scans, 5 reports",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F7056),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Edit", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F7056),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Give Feedback", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
