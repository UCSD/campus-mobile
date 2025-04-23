/// WAM Model used to hold the response from the ESRI "Nearby Search" API
class Place {
  final String name;
  final String location;
  final double distanceMi;
  final String businessHours;

  Place({
    required this.name,
    required this.location,
    required this.distanceMi,
    required this.businessHours,
  });
}