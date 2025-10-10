import 'package:flutter/material.dart';
import 'place_data.dart';
import 'place_model.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _distance = 50;
  double _dbRange = 50;
  bool _showPark = true;
  bool _showLibrary = true;
  String _searchText = '';
  String _sortOrder = 'Ascending';

  List<Place> _filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredPlaces = allPlaces.where((place) {
        if (place.db > _dbRange) return false;
        if (!_showPark && place.type == "Park") return false;
        if (!_showLibrary && place.type == "Library") return false;
        if (_searchText.isNotEmpty &&
            !place.name.toLowerCase().contains(_searchText.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();

      if (_sortOrder == 'Ascending') {
        _filteredPlaces.sort((a, b) => a.db.compareTo(b.db));
      } else {
        _filteredPlaces.sort((a, b) => b.db.compareTo(a.db));
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _distance = 50;
      _dbRange = 50;
      _showPark = true;
      _showLibrary = true;
      _searchText = '';
      _sortOrder = 'Ascending';
    });
    _applyFilters();
  }

  void _applyAndReturn() {
    Navigator.pop(context, _filteredPlaces); // send back to Explore screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E9C84),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E9C84),
        title: const Text(
          "Find Your Quiet Place",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filter By Type, Distance & Noise Level",
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 16),

            // Search Bar
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
                    borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
                _applyFilters();
              },
            ),
            const SizedBox(height: 16),

            const Text("Distance", style: TextStyle(color: Colors.white)),
            Slider(
              value: _distance,
              min: 0,
              max: 100,
              divisions: 10,
              label: '${_distance.round()} km',
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
              onChanged: (value) {
                setState(() => _distance = value);
              },
            ),

            const Text("dB Range", style: TextStyle(color: Colors.white)),
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

            Row(
              children: [
                Checkbox(
                  value: _showPark,
                  activeColor: Colors.white,
                  checkColor: const Color(0xFF3F7056),
                  onChanged: (value) {
                    setState(() => _showPark = value!);
                    _applyFilters();
                  },
                ),
                const Text("Park", style: TextStyle(color: Colors.white)),
                const SizedBox(width: 16),
                Checkbox(
                  value: _showLibrary,
                  activeColor: Colors.white,
                  checkColor: const Color(0xFF3F7056),
                  onChanged: (value) {
                    setState(() => _showLibrary = value!);
                    _applyFilters();
                  },
                ),
                const Text("Library", style: TextStyle(color: Colors.white)),
              ],
            ),

            // Sort Dropdown
            DropdownButton<String>(
              value: _sortOrder,
              dropdownColor: const Color(0xFF3F7056),
              items: ['Ascending', 'Descending'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _sortOrder = value!);
                _applyFilters();
              },
            ),

            const SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: _applyAndReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3F7056),
                  ),
                  child: const Text("Apply"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Reset"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Filtered List
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: ListView.builder(
                  key: ValueKey(_filteredPlaces.length),
                  itemCount: _filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _filteredPlaces[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F7056),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(place.name,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white)),
                          Text('${place.db} dB',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white70)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
