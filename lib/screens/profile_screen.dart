import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_nav_bar.dart';
import 'feedback_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = "User123";
  double _preferredDb = 40;
  List<String> _selectedTags = ['Reading', 'Meditation', 'Study'];
  final List<String> _availableTags = ['Reading', 'Meditation', 'Study', 'Relaxing', 'Work'];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "User123";
      _preferredDb = prefs.getDouble('preferredDb') ?? 40;
      _selectedTags = prefs.getStringList('tags') ?? ['Reading', 'Meditation', 'Study'];
      _isLoading = false;
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username);
    await prefs.setDouble('preferredDb', _preferredDb);
    await prefs.setStringList('tags', _selectedTags);
  }

  void _editUsernameDialog() {
    final controller = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Enter new username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _username = controller.text);
              _saveProfileData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      _saveProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF6E9C84),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

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
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF3F7056),
                child: Icon(Icons.person, size: 60, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                _username,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _editUsernameDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F7056),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Edit Username"),
              ),
              const SizedBox(height: 28),

              // Preferred dB range
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
                label: '${_preferredDb.round()} dB',
                onChanged: (value) {
                  setState(() => _preferredDb = value);
                  _saveProfileData();
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Interests",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return ChoiceChip(
                    label: Text(tag, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                    selected: isSelected,
                    selectedColor: Colors.white,
                    backgroundColor: const Color(0xFF3F7056),
                    onSelected: (_) => _toggleTag(tag),
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
      ),
    );
  }
}
