import 'place_model.dart';

// ✅ Updated place list with lat/lng
List<Place> allPlaces = [
  Place(name: "Library", db: 38, type: "Study Zone", isQuiet: true, latitude: 37.7749, longitude: -122.4194),
  Place(name: "Central Park", db: 45, type: "Park", isQuiet: true, latitude: 40.7851, longitude: -73.9683),
  Place(name: "Café Aroma", db: 70, type: "Café", isQuiet: false, latitude: 34.0522, longitude: -118.2437),
  Place(name: "Bus Stop", db: 85, type: "Transit", isQuiet: false, latitude: 51.5074, longitude: -0.1278),
  Place(name: "Lakeside", db: 42, type: "Relax Area", isQuiet: true, latitude: 48.8566, longitude: 2.3522),
  Place(name: "Food Court", db: 75, type: "Canteen", isQuiet: false, latitude: 35.6895, longitude: 139.6917),
];

// ✅ Current filtered places (initially same as all)
List<Place> filteredPlaces = List.from(allPlaces);

// ✅ Apply filter logic
void applyFilter({
  double? maxDb,
  String? type,
  bool? quietOnly,
}) {
  filteredPlaces = allPlaces.where((place) {
    final matchDb = maxDb == null || place.db <= maxDb;
    final matchType = type == null || type == 'All' || place.type == type;
    final matchQuiet = quietOnly == null || place.isQuiet == quietOnly;
    return matchDb && matchType && matchQuiet;
  }).toList();
}
