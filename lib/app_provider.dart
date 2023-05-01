import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/core/providers/connectivity.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/core/providers/location.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/providers/notices.dart';
import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/notifications_freefood.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/core/providers/scanner.dart';
import 'package:campus_mobile_experimental/core/providers/scanner_message.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/core/providers/speed_test.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
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
  ChangeNotifierProvider<InternetConnectivityProvider>(
    create: (_) {
      print("CreateProvider: InternetConnectivityProvider");
      InternetConnectivityProvider _connectivityProvider =
          InternetConnectivityProvider();
      _connectivityProvider.monitorInternet();
      return _connectivityProvider;
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
  ChangeNotifierProxyProvider2<Coordinates, UserDataProvider,
      ShuttleDataProvider>(create: (_) {
    var shuttleDataProvider = ShuttleDataProvider();
    return shuttleDataProvider;
  }, update: (_, coordinates, userDataProvider, shuttleDataProvider) {
    print("UpdateProvider: shuttleDataProvider");
    shuttleDataProvider!.userCoords = coordinates;
    shuttleDataProvider.userDataProvider = userDataProvider;
    shuttleDataProvider.fetchStops(true);
    return shuttleDataProvider;
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
];
List<SingleChildWidget> uiConsumableProviders = [];
