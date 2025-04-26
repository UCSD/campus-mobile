/// WAM Model used to further filter the response from the ESRI "Nearby Search" API
/// This model is used to build the What's Around Me List
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