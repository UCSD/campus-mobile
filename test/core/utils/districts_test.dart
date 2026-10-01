import 'package:campus_mobile_experimental/core/utils/districts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadCampusDistricts();
  });

  test('resolves a point inside the Muir polygon to Muir', () {
    expect(districtForLocation(32.8783, -117.2409), 'Muir');
  });

  test('resolves a point inside a multi-ring feature (Torrey Pines)', () {
    expect(districtForLocation(32.88898283018868, -117.24564528301886), 'Torrey Pines');
  });

  test('resolves a point outside all campus polygons to Other', () {
    expect(districtForLocation(40.0, -100.0), 'Other');
  });
}
