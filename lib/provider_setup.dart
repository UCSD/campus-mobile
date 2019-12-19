import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/core/services/dining_service.dart';
import 'package:campus_mobile_experimental/core/services/event_service.dart';
import 'package:campus_mobile_experimental/core/services/location_service.dart';
import 'package:campus_mobile_experimental/core/models/coordinates_model.dart';
import 'package:campus_mobile_experimental/ui/widgets/navigation/app_bar.dart';
import 'package:provider/provider.dart';

List<SingleChildCloneableWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];
List<SingleChildCloneableWidget> independentServices = [
  ChangeNotifierProvider<UserDataProvider>(
    builder: (_) => UserDataProvider(),
  ),
  ChangeNotifierProvider<BottomNavigationBarProvider>(
    builder: (_) => BottomNavigationBarProvider(),
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
];
List<SingleChildCloneableWidget> dependentServices = [
  ChangeNotifierProvider<DiningService>(
    builder: (_) => DiningService(),
  ),
  ChangeNotifierProxyProvider<UserDataProvider, ParkingDataProvider>(
    initialBuilder: (_) {
      var parkingDataProvider = ParkingDataProvider();
      parkingDataProvider.fetchParkingLots();
      return parkingDataProvider;
    },
    builder: (_, userDataProvider, parkingDataProvider) =>
        parkingDataProvider..userDataProvider = userDataProvider,
  ),
  ChangeNotifierProxyProvider<UserDataProvider, AvailabilityDataProvider>(
    initialBuilder: (_) {
      var availabilityDataProvider = AvailabilityDataProvider();
      availabilityDataProvider.fetchAvailability();
      return availabilityDataProvider;
    },
    builder: (_, userDataProvider, availabilityDataProvider) =>
        availabilityDataProvider..userDataProvider = userDataProvider,
  ),
];
List<SingleChildCloneableWidget> uiConsumableProviders = [];
