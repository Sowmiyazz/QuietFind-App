import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedType = 'Suggest location';
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _types = [
    'Suggest location',
    'Report issue',
    'General feedback',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final prefs = await SharedPreferences.getInstance();

    final feedback = {
      'type': _selectedType,
      'location': _locationController.text.trim(),
      'description': _descriptionController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Load existing feedbacks
    final existing = prefs.getStringList('feedbacks') ?? [];
    existing.add(jsonEncode(feedback));

    // Save back to local storage
    await prefs.setStringList('feedbacks', existing);

    // Clear form
    _locationController.clear();
    _descriptionController.clear();
    setState(() => _selectedType = 'Suggest location');

    // Confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Feedback submitted successfully!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E9C84),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E9C84),
        title: const Text(
          "Feedback / Suggest a Spot",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final feedbacks = prefs.getStringList('feedbacks') ?? [];
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF3F7056),
                  title: const Text('Previous Feedbacks', style: TextStyle(color: Colors.white)),
                  content: feedbacks.isEmpty
                      ? const Text('No feedbacks yet.', style: TextStyle(color: Colors.white70))
                      : SizedBox(
                          width: double.maxFinite,
                          height: 300,
                          child: ListView(
                            children: feedbacks.map((f) {
                              final data = jsonDecode(f);
                              return ListTile(
                                title: Text(
                                  "${data['type']} - ${data['location']}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  data['description'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type
              const Text("Type", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F7056),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: _types
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                  dropdownColor: const Color(0xFF3F7056),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),

              const SizedBox(height: 24),

              // Location
              const Text("Location", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Address or Name",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF3F7056),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Description
              const Text("Description", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write something...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF3F7056),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Center(
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F7056),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Thanks for improving QuietFind!",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
