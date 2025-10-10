class Place {
  String name;
  int db; // decibel level
  String type; // e.g., Cafe, Park, Library
  bool isQuiet;
  bool isSaved;

  Place({
    required this.name,
    required this.db,
    required this.type,
    this.isQuiet = true,
    this.isSaved = false,
  });
}
