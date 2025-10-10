import 'place_model.dart';

// ✅ Original place list
List<Place> allPlaces = [
  Place(name: "Library", db: 38, type: "Study Zone", isQuiet: true),
  Place(name: "Central Park", db: 45, type: "Park", isQuiet: true),
  Place(name: "Café Aroma", db: 70, type: "Café", isQuiet: false),
  Place(name: "Bus Stop", db: 85, type: "Transit", isQuiet: false),
  Place(name: "Lakeside", db: 42, type: "Relax Area", isQuiet: true),
  Place(name: "Food Court", db: 75, type: "Canteen", isQuiet: false),
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
