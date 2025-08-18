/// WAM Model used to further filter the response from the ESRI "Points of Interest" API
/// This model is used to build the What's Around Me list contents
class Place {
  final String name;
  final String location;
  final double distanceFromUser;
  final String category;

  Place({
    required this.name,
    required this.location,
    required this.distanceFromUser,
    required this.category,
  });

  @override
  String toString() {
    return 'Place(name: $name, location: $location, distanceFromUser: $distanceFromUser, category: $category)';
  }
}