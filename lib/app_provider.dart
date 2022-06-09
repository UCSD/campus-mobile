import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/core/providers/employee_id.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/core/providers/location.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/providers/news.dart';
import 'package:campus_mobile_experimental/core/providers/notices.dart';
import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/notifications_freefood.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/core/providers/scanner.dart';
import 'package:campus_mobile_experimental/core/providers/scanner_message.dart';
import 'package:campus_mobile_experimental/core/providers/speed_test.dart';
import 'package:campus_mobile_experimental/core/providers/student_id.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/providers/ventilation.dart';
import 'package:campus_mobile_experimental/core/providers/wayfinding.dart';
import 'package:campus_mobile_experimental/core/providers/weather.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];
LocationDataProvider? locationProvider;
final FirebaseAnalytics analytics = FirebaseAnalytics();
final FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

List<SingleChildWidget> independentServices = [
  Provider.value(value: observer),
  ChangeNotifierProvider<BottomNavigationBarProvider>(
    create: (_) {
      return BottomNavigationBarProvider();
    },
    lazy: false,
  ),
  ChangeNotifierProvider<PushNotificationDataProvider>(
    create: (_) {
      return PushNotificationDataProvider();
    },
    lazy: false,
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
  StreamProvider<Coordinates>(
    initialData: Coordinates(),
    create: (_) {
      locationProvider = LocationDataProvider();
      return locationProvider!.locationStream;
    },
    lazy: false,
  ),
  ChangeNotifierProvider<CustomAppBar>(
    create: (_) {
      return CustomAppBar();
    },
  ),
  ChangeNotifierProvider<NoticesDataProvider>(
    create: (_) {
      NoticesDataProvider _noticesDataProvider = NoticesDataProvider();
      _noticesDataProvider.fetchNotices();
      return _noticesDataProvider;
    },
  ),
];
List<SingleChildWidget> dependentServices = [
  ChangeNotifierProxyProvider<Coordinates, DiningDataProvider>(create: (_) {
    var diningDataProvider = DiningDataProvider();
    diningDataProvider.fetchDiningLocations();
    return diningDataProvider;
  }, update: (_, coordinates, diningDataProvider) {
    diningDataProvider!.coordinates = coordinates;
    diningDataProvider.populateDistances();
    return diningDataProvider;
  }),
  ChangeNotifierProxyProvider<Coordinates, MapsDataProvider>(create: (_) {
    var mapsDataProvider = MapsDataProvider();
    return mapsDataProvider;
  }, update: (_, coordinates, mapsDataProvider) {
    mapsDataProvider!.coordinates = coordinates;
    mapsDataProvider.populateDistances();
    return mapsDataProvider;
  }),
  ChangeNotifierProxyProvider<PushNotificationDataProvider, UserDataProvider>(
      create: (_) {
        var _userDataProvider = UserDataProvider();

        /// try to load any persistent saved data
        /// once loaded from memory get the user's online profile
        _userDataProvider
            .loadSavedData()
            .whenComplete(() => _userDataProvider.fetchUserProfile());
        return _userDataProvider;
      },
      lazy: false,
      update: (_, pushNotificationDataProvider, _userDataProvider) {
        _userDataProvider!.pushNotificationDataProvider =
            pushNotificationDataProvider;
        return _userDataProvider;
      }),
  ChangeNotifierProxyProvider<UserDataProvider, CardsDataProvider>(
      create: (_) {
        var cardsDataProvider = CardsDataProvider();
        return cardsDataProvider;
      },
      lazy: false,
      update: (_, userDataProvider, cardsDataProvider) {
        cardsDataProvider!.userDataProvider = userDataProvider;
        userDataProvider.cardsDataProvider = cardsDataProvider;
        cardsDataProvider
          ..loadSavedData().then((value) {
            // Update available cards
            cardsDataProvider.updateAvailableCards(
                userDataProvider.authenticationModel!.ucsdaffiliation);

            // Student card activation
            if (userDataProvider.isLoggedIn &&
                (userDataProvider.userProfileModel!.classifications?.student ??
                    false)) {
              cardsDataProvider.activateStudentCards();
            } else {
              cardsDataProvider.deactivateStudentCards();
            }

            // Staff card activation
            if (userDataProvider.isLoggedIn &&
                (userDataProvider.userProfileModel!.classifications?.staff ??
                    false)) {
              cardsDataProvider.activateStaffCards();
            } else {
              cardsDataProvider.deactivateStaffCards();
            }
          });
        return cardsDataProvider;
      }),
  ChangeNotifierProxyProvider<UserDataProvider, ClassScheduleDataProvider>(
      create: (_) {
    var classDataProvider = ClassScheduleDataProvider();
    return classDataProvider;
  }, update: (_, userDataProvider, classScheduleDataProvider) {
    classScheduleDataProvider!.userDataProvider = userDataProvider;
    if (userDataProvider.isLoggedIn && !classScheduleDataProvider.isLoading!) {
      classScheduleDataProvider.fetchData();
    }
    return classScheduleDataProvider;
  }),
  ChangeNotifierProxyProvider2<Coordinates, UserDataProvider,
      WayfindingProvider>(create: (_) {
    var proximityAwarenessSingleton = WayfindingProvider();
    return proximityAwarenessSingleton;
  }, update: (_, coordinates, userDataProvider, proximityAwarenessSingleton) {
    proximityAwarenessSingleton!
        .coordinateAndLocation(coordinates, locationProvider!);
    proximityAwarenessSingleton.userProvider = userDataProvider;
    return proximityAwarenessSingleton;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, StudentIdDataProvider>(
      create: (_) {
    var studentIdDataProvider = StudentIdDataProvider();
    return studentIdDataProvider;
  }, update: (_, userDataProvider, studentIdDataProvider) {
    studentIdDataProvider!.userDataProvider = userDataProvider;
    //Verify that the user is logged in
    if (userDataProvider.isLoggedIn && !studentIdDataProvider.isLoading!) {
      studentIdDataProvider.fetchData();
    }
    return studentIdDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, EmployeeIdDataProvider>(
      create: (_) {
    var employeeIdDataProvider = EmployeeIdDataProvider();
    return employeeIdDataProvider;
  }, update: (_, userDataProvider, employeeIdDataProvider) {
    employeeIdDataProvider!.userDataProvider = userDataProvider;
    //Verify that the user is logged in
    if (userDataProvider.isLoggedIn && !employeeIdDataProvider.isLoading!) {
      employeeIdDataProvider.fetchData();
    }
    return employeeIdDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, ScannerMessageDataProvider>(
      create: (_) {
    var scannerMessageDataProvider = ScannerMessageDataProvider();
    return scannerMessageDataProvider;
  }, update: (_, userDataProvider, scannerMessageDataProvider) {
    scannerMessageDataProvider!.userDataProvider = userDataProvider;
    //Verify that the user is logged in
    if (userDataProvider.isLoggedIn && !scannerMessageDataProvider.isLoading!) {
      scannerMessageDataProvider.fetchData();
    }
    return scannerMessageDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, AvailabilityDataProvider>(
      create: (_) {
    var availabilityDataProvider = AvailabilityDataProvider();
    availabilityDataProvider.fetchAvailability();
    return availabilityDataProvider;
  }, update: (_, userDataProvider, availabilityDataProvider) {
    availabilityDataProvider!.userDataProvider = userDataProvider;
    return availabilityDataProvider;
  }),
  ChangeNotifierProxyProvider2<Coordinates, UserDataProvider,
      SpeedTestProvider>(create: (_) {
    SpeedTestProvider speedTestProvider = SpeedTestProvider();
    speedTestProvider.init();
    return speedTestProvider;
  }, update: (_, coordinates, userDataProvider, speedTestProvider) {
    speedTestProvider!.coordinates = coordinates;
    speedTestProvider.userDataProvider = userDataProvider;
    return speedTestProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, ParkingDataProvider>(
      create: (_) {
    var parkingDataProvider = ParkingDataProvider();
    return parkingDataProvider;
  }, update: (_, userDataProvider, parkingDataProvider) {
    parkingDataProvider!.userDataProvider = userDataProvider;
    parkingDataProvider.fetchParkingData();
    return parkingDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, MessagesDataProvider>(
    create: (_) {
      var messageDataProvider = MessagesDataProvider();
      return messageDataProvider;
    },
    lazy: false,
    update: (_, userDataProvider, messageDataProvider) {
      messageDataProvider!.userDataProvider = userDataProvider;
      messageDataProvider.fetchMessages(true);
      return messageDataProvider;
    },
  ),
  ChangeNotifierProxyProvider<MessagesDataProvider, FreeFoodDataProvider>(
    create: (_) {
      var freefoodDataProvider = FreeFoodDataProvider();
      freefoodDataProvider.loadRegisteredEvents();
      return freefoodDataProvider;
    },
    update: (_, messageDataProvider, freefoodDataProvider) {
      freefoodDataProvider!.messageDataProvider = messageDataProvider;
      freefoodDataProvider.parseMessages();
      return freefoodDataProvider;
    },
  ),
  ChangeNotifierProxyProvider<UserDataProvider, ScannerDataProvider>(
    create: (_) {
      var _scannerDataProvider = ScannerDataProvider();
      _scannerDataProvider.initState();
      _scannerDataProvider.setDefaultStates();
      return _scannerDataProvider;
    },
    update: (_, _userDataProvider, scannerDataProvider) {
      scannerDataProvider!.userDataProvider = _userDataProvider;
      scannerDataProvider.initState();
      scannerDataProvider.setDefaultStates();
      return scannerDataProvider;
    },
    lazy: false,
  ),
  ChangeNotifierProxyProvider<UserDataProvider, VentilationDataProvider>(
      create: (_) {
    var ventilationDataProvider = VentilationDataProvider();
    ventilationDataProvider.fetchLocationsAndData();
    return ventilationDataProvider;
  }, update: (_, userDataProvider, ventilationDataProvider) {
    ventilationDataProvider!.userDataProvider = userDataProvider;
    ventilationDataProvider.fetchVentilationData();
    return ventilationDataProvider;
  })
];
List<SingleChildWidget> uiConsumableProviders = [];
