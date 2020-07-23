import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/core/providers/location.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/providers/news.dart';
import 'package:campus_mobile_experimental/core/providers/notices.dart';
import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/scanner.dart';
import 'package:campus_mobile_experimental/core/providers/student_id.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/providers/weather.dart';
import 'package:campus_mobile_experimental/core/services/bottom_nav.dart';
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

final FirebaseAnalytics analytics = FirebaseAnalytics();
final FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

List<SingleChildWidget> independentServices = [
  Provider.value(value: observer),
  ChangeNotifierProvider<BottomNavigationBarProvider>(
    create: (_) => BottomNavigationBarProvider(),
    lazy: false,
  ),
  ChangeNotifierProvider<PushNotificationDataProvider>(
    create: (_) => PushNotificationDataProvider(),
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
    create: (_) => LocationDataProvider().locationStream,
  ),
  ChangeNotifierProvider<CustomAppBar>(
    create: (_) => CustomAppBar(),
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
    diningDataProvider.coordinates = coordinates;
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
        _userDataProvider.pushNotificationDataProvider =
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
        cardsDataProvider
          ..loadSavedData().then((value) {
            cardsDataProvider.updateAvailableCards();
            if (userDataProvider.isLoggedIn &&
                (userDataProvider.userProfileModel.classifications?.student ??
                    false)) {
              cardsDataProvider.activateStudentCards();
            } else {
              /// this is getting called before loadSaved data is complete
              cardsDataProvider.deactivateStudentCards();
            }
          });
        return cardsDataProvider;
      }),
  ChangeNotifierProxyProvider<UserDataProvider, ClassScheduleDataProvider>(
      create: (_) {
    var classDataProvider = ClassScheduleDataProvider();
    return classDataProvider;
  }, update: (_, userDataProvider, classScheduleDataProvider) {
    classScheduleDataProvider.userDataProvider = userDataProvider;
    if (userDataProvider.isLoggedIn && !classScheduleDataProvider.isLoading) {
      classScheduleDataProvider.fetchData();
    }
    return classScheduleDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, BarcodeDataProvider>(
      create: (_) {
    var barcodeDataProvider = BarcodeDataProvider();
    return barcodeDataProvider;
  }, update: (_, userDataProvider, barcodeDataProvider) {
    barcodeDataProvider.userDataProvider = userDataProvider;
    return barcodeDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, StudentIdDataProvider>(
      create: (_) {
    var studentIdDataProvider = StudentIdDataProvider();
    return studentIdDataProvider;
  }, update: (_, userDataProvider, studentIdDataProvider) {
    studentIdDataProvider.userDataProvider = userDataProvider;

    //Verify that the user is logged in
    if (userDataProvider.isLoggedIn && !studentIdDataProvider.isLoading) {
      studentIdDataProvider.fetchData();
    }

    return studentIdDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, AvailabilityDataProvider>(
      create: (_) {
    var availabilityDataProvider = AvailabilityDataProvider();
    availabilityDataProvider.fetchAvailability();
    return availabilityDataProvider;
  }, update: (_, userDataProvider, availabilityDataProvider) {
    availabilityDataProvider.userDataProvider = userDataProvider;
    return availabilityDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, MessagesDataProvider>(
    create: (_) {
      var messageDataProvider = MessagesDataProvider();
      return messageDataProvider;
    },
    lazy: false,
    update: (_, userDataProvider, messageDataProvider) {
      messageDataProvider.userDataProvider = userDataProvider;
      messageDataProvider.fetchMessages(true);
      return messageDataProvider;
    },
  ),
];
List<SingleChildWidget> uiConsumableProviders = [];
