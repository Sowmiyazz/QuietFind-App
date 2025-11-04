class Place {
  String name;
  double db; // decibel level
  String type; // e.g., Cafe, Park, Library
  bool isQuiet;
  bool isSaved;
  double latitude; // latitude
  double longitude; // longitude

  Place({
    required this.name,
    required this.db,
    required this.type,
    this.isQuiet = true,
    this.isSaved = false,
    required this.latitude,
    required this.longitude,
  });
}
