import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'place_model.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _dbRange = 90;
  String _searchText = '';
  String _sortOrder = 'Ascending';

  bool _showParks = true;
  bool _showLibraries = true;
  bool _showCafes = true;
  bool _showTransit = true;
  bool _showRelax = true;
  bool _showCanteens = true;

  List<Place> _allPlaces = [];
  List<Place> _filteredPlaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  /// 🔹 Load all places once from Firestore
  Future<void> _loadPlaces() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('places').get();

      _allPlaces = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Place(
          name: data['name'] ?? '',
          db: (data['db'] is num) ? (data['db'] as num).toDouble() : 0.0,
          type: data['type'] ?? '',
          isQuiet: data['isQuiet'] ?? true,
          isSaved: data['isSaved'] ?? false,
        );
      }).toList();

      _applyFilters(); // show filtered view initially
    } catch (e) {
      print("❌ Error loading places: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Apply filters locally (no Firestore query)
  void _applyFilters() {
    setState(() {
      List<String> selectedTypes = [];
      if (_showParks) selectedTypes.add("Park");
      if (_showLibraries) selectedTypes.add("Study Zone");
      if (_showCafes) selectedTypes.add("Café");
      if (_showTransit) selectedTypes.add("Transit");
      if (_showRelax) selectedTypes.add("Relax Area");
      if (_showCanteens) selectedTypes.add("Canteen");

      _filteredPlaces = _allPlaces.where((place) {
        final matchesDb = place.db <= _dbRange;
        final matchesType = selectedTypes.contains(place.type);
        final matchesSearch = place.name.toLowerCase().contains(_searchText.toLowerCase());
        return matchesDb && matchesType && matchesSearch;
      }).toList();

      // sort results
      if (_sortOrder == 'Ascending') {
        _filteredPlaces.sort((a, b) => a.db.compareTo(b.db));
      } else {
        _filteredPlaces.sort((a, b) => b.db.compareTo(a.db));
      }
    });
  }

  /// 🔹 Reset filters
  void _resetFilters() {
    setState(() {
      _dbRange = 90;
      _searchText = '';
      _sortOrder = 'Ascending';
      _showParks = _showLibraries = _showCafes =
          _showTransit = _showRelax = _showCanteens = true;
    });
    _applyFilters();
  }

  /// 🔹 Confirm & return filtered list to ExploreScreen
  void _confirmFilters() {
    Navigator.pop(context, _filteredPlaces);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E9C84),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E9C84),
        title: const Text(
          "Find Your Quiet Place",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text("Clear",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter By Type & Noise Level",
                      style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 16),

                  // 🔍 Search Bar
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by place name...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFF3F7056),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      _searchText = value;
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🎚️ dB Range
                  const Text("Maximum dB Level",
                      style: TextStyle(color: Colors.white)),
                  Slider(
                    value: _dbRange,
                    min: 30,
                    max: 90,
                    divisions: 12,
                    label: '${_dbRange.round()} dB',
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      setState(() => _dbRange = value);
                      _applyFilters();
                    },
                  ),

                  // 🏷️ Type checkboxes
                  Wrap(
                    spacing: 10,
                    runSpacing: -10,
                    children: [
                      _buildTypeCheckbox("Park", _showParks,
                          (val) => setState(() {
                                _showParks = val!;
                                _applyFilters();
                              })),
                      _buildTypeCheckbox("Study Zone", _showLibraries,
                          (val) => setState(() {
                                _showLibraries = val!;
                                _applyFilters();
                              })),
                      _buildTypeCheckbox("Café", _showCafes,
                          (val) => setState(() {
                                _showCafes = val!;
                                _applyFilters();
                              })),
                      _buildTypeCheckbox("Transit", _showTransit,
                          (val) => setState(() {
                                _showTransit = val!;
                                _applyFilters();
                              })),
                      _buildTypeCheckbox("Relax Area", _showRelax,
                          (val) => setState(() {
                                _showRelax = val!;
                                _applyFilters();
                              })),
                      _buildTypeCheckbox("Canteen", _showCanteens,
                          (val) => setState(() {
                                _showCanteens = val!;
                                _applyFilters();
                              })),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 🔄 Sort dropdown
                  DropdownButton<String>(
                    value: _sortOrder,
                    dropdownColor: const Color(0xFF3F7056),
                    items: ['Ascending', 'Descending'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _sortOrder = value!);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "Showing ${_filteredPlaces.length} results",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  // 📋 Filtered list preview
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredPlaces.length,
                      itemBuilder: (context, index) {
                        final place = _filteredPlaces[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F7056),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(place.name,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white)),
                                  Text(place.type,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                              Text('${place.db.toStringAsFixed(1)} dB',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white70)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // ✅ Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3F7056),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Confirm & Return to Map",
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeCheckbox(
      String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: Colors.white,
          checkColor: const Color(0xFF3F7056),
          onChanged: onChanged,
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
