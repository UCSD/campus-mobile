/// WAM Model used to hold the response from the ESRI "Nearby Search" API
class Place {
  final String name;
  final String location;
  final double distanceMeters;
  final String category;

  Place({
    required this.name,
    required this.location,
    required this.distanceMeters,
    required this.category,
  });
}