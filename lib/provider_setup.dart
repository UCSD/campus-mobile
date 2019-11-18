import 'package:campus_mobile_experimental/core/services/availability_service.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/core/services/dining_service.dart';
import 'package:campus_mobile_experimental/core/services/event_service.dart';
import 'package:campus_mobile_experimental/core/services/location_service.dart';
import 'package:campus_mobile_experimental/core/models/coordinates_model.dart';
import 'package:campus_mobile_experimental/ui/widgets/navigation/app_bar.dart';
import 'package:campus_mobile_experimental/core/services/parking_service.dart';
import 'package:provider/provider.dart';

List<SingleChildCloneableWidget> providers = [
  ChangeNotifierProvider<BottomNavigationBarProvider>(
    builder: (_) => BottomNavigationBarProvider(),
  ),
  ChangeNotifierProvider<AvailabilityService>(
    builder: (_) => AvailabilityService(),
  ),
  ChangeNotifierProvider<EventsService>(
    builder: (_) => EventsService(),
  ),
  StreamProvider<Coordinates>(
    builder: (_) => LocationService().locationStream,
  ),
  ChangeNotifierProvider<CustomAppBar>(
    builder: (_) => CustomAppBar(),
  ),
  ChangeNotifierProvider<DiningService>(
    builder: (_) => DiningService(),
  ),
  ChangeNotifierProvider<ParkingService>(
    builder: (_) => ParkingService(),
  ),
];
