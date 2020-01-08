import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';
import 'package:campus_mobile_experimental/core/data_providers/events_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/links_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/location_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:campus_mobile_experimental/core/models/coordinates_model.dart';
import 'package:campus_mobile_experimental/ui/widgets/navigation/app_bar.dart';
import 'package:provider/provider.dart';

List<SingleChildCloneableWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];
List<SingleChildCloneableWidget> independentServices = [
  ChangeNotifierProvider<BottomNavigationBarProvider>(
    builder: (_) => BottomNavigationBarProvider(),
  ),
  ChangeNotifierProvider<UserDataProvider>(
    builder: (_) => UserDataProvider(),
  ),
  ChangeNotifierProvider<EventsDataProvider>(
    builder: (_) {
      EventsDataProvider _eventsDataProvider = EventsDataProvider();
      _eventsDataProvider.fetchEvents();
      return _eventsDataProvider;
    },
  ),
  ChangeNotifierProvider<LinksDataProvider>(
    builder: (_) {
      LinksDataProvider _linksDataProvider = LinksDataProvider();
      _linksDataProvider.fetchLinks();
      return _linksDataProvider;
    },
  ),
  StreamProvider<Coordinates>(
    builder: (_) => LocationDataProvider().locationStream,
  ),
  ChangeNotifierProvider<CustomAppBar>(
    builder: (_) => CustomAppBar(),
  ),
];
List<SingleChildCloneableWidget> dependentServices = [
  ChangeNotifierProxyProvider<Coordinates, DiningDataProvider>(
      initialBuilder: (_) {
    var diningDataProvider = DiningDataProvider();
    diningDataProvider.fetchDiningLocations();
    return diningDataProvider;
  }, builder: (_, coordinates, diningDataProvider) {
    diningDataProvider..coordinates = coordinates;
    diningDataProvider.populateDistances();
    return diningDataProvider;
  }),
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
