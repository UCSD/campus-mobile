import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/utils/districts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final eastNear = ShuttleStopModel(id: 1, name: 'Zulu East', lat: 32.879, lon: -117.223);
  final eastFar = ShuttleStopModel(id: 2, name: 'Alpha East', lat: 32.879, lon: -117.225);
  final west = ShuttleStopModel(id: 3, name: 'West', lat: 32.8783, lon: -117.2409);
  final other = ShuttleStopModel(id: 4, name: 'Other Stop', lat: 40, lon: -100);
  late ShuttleDataProvider provider;

  setUpAll(loadCampusDistricts);
  setUp(() {
    provider = ShuttleDataProvider()
      ..userDataProvider = UserDataProvider()
      ..fetchedStops = {
        for (final stop in [west, eastFar, other, eastNear]) stop.id: stop,
      };
    addTearDown(provider.dispose);
    addTearDown(provider.userDataProvider!.dispose);
  });

  test('closest stop and its district lead, and reorder as the user moves', () {
    provider.userCoords = Coordinates(lat: eastNear.lat, lon: eastNear.lon);
    var districts = provider.stopsNotSelectedByDistrict();
    expect(districts.keys, ['Health Sciences East', 'Muir', 'Other']);
    expect(districts.values.first, [eastNear, eastFar]);

    provider.userCoords = Coordinates(lat: eastFar.lat, lon: eastFar.lon);
    expect(provider.stopsNotSelectedByDistrict().values.first, [eastFar, eastNear]);

    provider.userCoords = Coordinates(lat: west.lat, lon: west.lon);
    districts = provider.stopsNotSelectedByDistrict();
    expect(districts.keys.first, 'Muir');
    expect(districts.values.first.first, west);
  });

  test('without a complete location, districts and stops remain alphabetical with Other last', () {
    for (final coords in [Coordinates(), Coordinates(lat: eastNear.lat), Coordinates(lon: eastNear.lon)]) {
      provider.userCoords = coords;
      final districts = provider.stopsNotSelectedByDistrict();
      expect(districts.keys, ['Health Sciences East', 'Muir', 'Other']);
      expect(districts.values.first, [eastFar, eastNear]);
    }
  });

  test('saved stops stay excluded and keep their manual order', () {
    provider.userCoords = Coordinates(lat: eastNear.lat, lon: eastNear.lon);
    provider.userDataProvider!.userProfileModel.selectedStops = [west.id, eastNear.id];
    final districts = provider.stopsNotSelectedByDistrict();
    expect(districts.values.expand((stops) => stops), [eastFar, other]);
    expect(provider.stopsToRender, [west, eastNear]);
    expect(provider.userDataProvider!.userProfileModel.selectedStops, [west.id, eastNear.id]);
    expect(provider.fetchedStops!.values, [west, eastFar, other, eastNear]);
  });

  test('search orders districts by their nearest matching stop', () {
    final near = ShuttleStopModel(id: 5, name: 'Nearby', lat: 32.8783, lon: -117.2378);
    final far = ShuttleStopModel(id: 6, name: 'Query Muir', lat: 32.8783, lon: -117.243);
    final neighbor = ShuttleStopModel(id: 7, name: 'Query University Center', lat: 32.8783, lon: -117.2375);
    provider.fetchedStops = {
      for (final stop in [far, neighbor, near]) stop.id: stop,
    };
    provider.userCoords = Coordinates(lat: near.lat, lon: near.lon);
    expect(provider.stopsNotSelectedByDistrict().keys.first, 'Muir');

    final districts = provider.stopsNotSelectedByDistrict(query: ' QUERY ');
    expect(districts.keys, ['University Center', 'Muir']);
    expect(districts.values.expand((stops) => stops), [neighbor, far]);
    expect(provider.stopsNotSelectedByDistrict(query: 'no match'), isEmpty);
  });

  test('Other can lead when it contains the closest stop', () {
    provider.userCoords = Coordinates(lat: other.lat, lon: other.lon);
    final districts = provider.stopsNotSelectedByDistrict();
    expect(districts.keys.first, 'Other');
    expect(districts.values.first.first, other);
  });

  test('no stops returns no sections', () {
    provider.fetchedStops = null;
    expect(provider.stopsNotSelectedByDistrict(), isEmpty);
  });
}
