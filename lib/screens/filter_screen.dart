import 'package:flutter/material.dart';
import 'place_data.dart';
import 'place_model.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _distance = 100; // Show all initially
  double _dbRange = 90;   // Show all initially
  String _searchText = '';
  String _sortOrder = 'Ascending';

  // Type filters
  bool _showParks = true;
  bool _showLibraries = true;
  bool _showCafes = true;
  bool _showTransit = true;
  bool _showRelax = true;
  bool _showCanteens = true;

  List<Place> _filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  // Dummy distances assigned to each place (in km)
  final Map<String, double> _dummyDistances = {
    "Library": 10,
    "Central Park": 25,
    "Café Aroma": 40,
    "Bus Stop": 60,
    "Lakeside": 35,
    "Food Court": 75,
  };

  void _applyFilters() {
    setState(() {
      _filteredPlaces = allPlaces.where((place) {
        // Distance filter
        double distance = _dummyDistances[place.name] ?? 0;
        if (distance > _distance) return false;

        // dB range filter
        if (place.db > _dbRange) return false;

        // Type filters
        if (!_showParks && place.type == "Park") return false;
        if (!_showLibraries && place.type == "Study Zone") return false;
        if (!_showCafes && place.type == "Café") return false;
        if (!_showTransit && place.type == "Transit") return false;
        if (!_showRelax && place.type == "Relax Area") return false;
        if (!_showCanteens && place.type == "Canteen") return false;

        // Search filter
        if (_searchText.isNotEmpty &&
            !place.name.toLowerCase().contains(_searchText.toLowerCase())) {
          return false;
        }

        return true;
      }).toList();

      // Sorting by dB
      if (_sortOrder == 'Ascending') {
        _filteredPlaces.sort((a, b) => a.db.compareTo(b.db));
      } else {
        _filteredPlaces.sort((a, b) => b.db.compareTo(a.db));
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _distance = 100;
      _dbRange = 90;
      _searchText = '';
      _sortOrder = 'Ascending';
      _showParks = _showLibraries = _showCafes =
          _showTransit = _showRelax = _showCanteens = true;
    });
    _applyFilters();
  }

  void _applyAndReturn() {
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
                _applyFilters();
              },
            ),
            const SizedBox(height: 16),

            // Distance slider
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
                _applyFilters();
              },
            ),

            // dB Range slider
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

            // Type filters (checkboxes)
            Wrap(
              spacing: 10,
              runSpacing: -10,
              children: [
                _buildTypeCheckbox("Park", _showParks, (val) {
                  setState(() => _showParks = val!);
                  _applyFilters();
                }),
                _buildTypeCheckbox("Study Zone", _showLibraries, (val) {
                  setState(() => _showLibraries = val!);
                  _applyFilters();
                }),
                _buildTypeCheckbox("Café", _showCafes, (val) {
                  setState(() => _showCafes = val!);
                  _applyFilters();
                }),
                _buildTypeCheckbox("Transit", _showTransit, (val) {
                  setState(() => _showTransit = val!);
                  _applyFilters();
                }),
                _buildTypeCheckbox("Relax Area", _showRelax, (val) {
                  setState(() => _showRelax = val!);
                  _applyFilters();
                }),
                _buildTypeCheckbox("Canteen", _showCanteens, (val) {
                  setState(() => _showCanteens = val!);
                  _applyFilters();
                }),
              ],
            ),

            // Sort dropdown
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

            const SizedBox(height: 10),

            // Result count
            Text(
              "${_filteredPlaces.length} results found",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),

            // Filtered List
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: ListView.builder(
                  key: ValueKey(_filteredPlaces.length),
                  itemCount: _filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _filteredPlaces[index];
                    double distance = _dummyDistances[place.name] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                              Text("${place.type} • ${distance.toStringAsFixed(1)} km",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white70)),
                            ],
                          ),
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
