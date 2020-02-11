import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';
import 'package:campus_mobile_experimental/core/data_providers/events_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/links_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/location_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/maps_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/news_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/special_events_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/surf_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/weather_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/coordinates_model.dart';
import 'package:campus_mobile_experimental/core/navigation/top_navigation_bar/app_bar.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];
List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider<BottomNavigationBarProvider>(
    create: (_) => BottomNavigationBarProvider(),
  ),
  ChangeNotifierProvider<UserDataProvider>(
    create: (_) => UserDataProvider(),
  ),
  ChangeNotifierProvider<SurfDataProvider>(
    create: (_) {
      SurfDataProvider _surfDataProvider = SurfDataProvider();
      _surfDataProvider.fetchSurfData();
      return _surfDataProvider;
    },
  ),
  ChangeNotifierProvider<SpecialEventsDataProvider>(
    create: (_) {
      SpecialEventsDataProvider _specialEventsDataProvider =
          SpecialEventsDataProvider();
      _specialEventsDataProvider.fetchData();
      return _specialEventsDataProvider;
    },
  ),
  ChangeNotifierProvider<EventsDataProvider>(
    create: (_) {
      EventsDataProvider _eventsDataProvider = EventsDataProvider();
      _eventsDataProvider.fetchEvents();
      return _eventsDataProvider;
    },
  ),
  ChangeNotifierProvider<WeatherDataProvider>(
    create: (_) {
      WeatherDataProvider _weatherDataProvider = WeatherDataProvider();
      _weatherDataProvider.fetchWeather();
      return _weatherDataProvider;
    },
  ),
  ChangeNotifierProvider<NewsDataProvider>(
    create: (_) {
      NewsDataProvider _newsDataProvider = NewsDataProvider();
      _newsDataProvider.fetchNews();
      return _newsDataProvider;
    },
  ),
  ChangeNotifierProvider<LinksDataProvider>(
    create: (_) {
      LinksDataProvider _linksDataProvider = LinksDataProvider();
      _linksDataProvider.fetchLinks();
      return _linksDataProvider;
    },
  ),
  StreamProvider<Coordinates>(
    create: (_) => LocationDataProvider().locationStream,
  ),
  ChangeNotifierProvider<CustomAppBar>(
    create: (_) => CustomAppBar(),
  ),
];
List<SingleChildWidget> dependentServices = [
  ChangeNotifierProxyProvider<Coordinates, DiningDataProvider>(create: (_) {
    var diningDataProvider = DiningDataProvider();
    diningDataProvider.fetchDiningLocations();
    return diningDataProvider;
  }, update: (_, coordinates, diningDataProvider) {
    diningDataProvider..coordinates = coordinates;
    diningDataProvider.populateDistances();
    return diningDataProvider;
  }),
  ChangeNotifierProxyProvider<Coordinates, MapsDataProvider>(create: (_) {
    var mapsDataProvider = MapsDataProvider();
    return mapsDataProvider;
  }, update: (_, coordinates, mapsDataProvider) {
    mapsDataProvider.coordinates = coordinates;
    mapsDataProvider.populateDistances();
    return mapsDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, ParkingDataProvider>(
    create: (_) {
      var parkingDataProvider = ParkingDataProvider();
      parkingDataProvider.fetchParkingLots();
      return parkingDataProvider;
    },
    update: (_, userDataProvider, parkingDataProvider) =>
        parkingDataProvider..userDataProvider = userDataProvider,
  ),
  ChangeNotifierProxyProvider<UserDataProvider, AvailabilityDataProvider>(
    create: (_) {
      var availabilityDataProvider = AvailabilityDataProvider();
      availabilityDataProvider.fetchAvailability();
      return availabilityDataProvider;
    },
    update: (_, userDataProvider, availabilityDataProvider) =>
        availabilityDataProvider..userDataProvider = userDataProvider,
  ),
];
List<SingleChildWidget> uiConsumableProviders = [];
