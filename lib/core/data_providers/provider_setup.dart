import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/barcode_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/class_schedule_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';
import 'package:campus_mobile_experimental/core/data_providers/events_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/free_food_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/links_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/location_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/news_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/notices_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/push_notifications_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/special_events_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/student_id_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/surf_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/weather_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/coordinates_model.dart';
import 'package:campus_mobile_experimental/core/navigation/top_navigation_bar/app_bar.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'maps_data_provider.dart';

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
              cardsDataProvider.deactivateStudentCards();
            }

            if (userDataProvider.isLoggedIn &&
                (userDataProvider.userProfileModel.classifications?.staff ??
                    false)) {
              cardsDataProvider.activateStaffCards();
            } else {
              cardsDataProvider.deactivateStaffCards();
            }

            if (userDataProvider.isLoggedIn) {
              cardsDataProvider.deactivateSignedOutCards();
            } else {
              cardsDataProvider.activateSignedOutCards();
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
  ChangeNotifierProxyProvider<UserDataProvider, ParkingDataProvider>(
      create: (_) {
    var parkingDataProvider = ParkingDataProvider();
    return parkingDataProvider;
  }, update: (_, userDataProvider, parkingDataProvider) {
    parkingDataProvider.userDataProvider = userDataProvider;
    parkingDataProvider.fetchSpotTypes();
    parkingDataProvider.fetchParkingLots();
    return parkingDataProvider;
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
  ChangeNotifierProxyProvider<MessagesDataProvider, FreeFoodDataProvider>(
    create: (_) {
      var freefoodDataProvider = FreeFoodDataProvider();
      freefoodDataProvider..loadRegisteredEvents();

      return freefoodDataProvider;
    },
    update: (_, messageDataProvider, freefoodDataProvider) {
      freefoodDataProvider..messageDataProvider = messageDataProvider;
      freefoodDataProvider.parseMessages();
      return freefoodDataProvider;
    },
  ),
];
List<SingleChildWidget> uiConsumableProviders = [];
