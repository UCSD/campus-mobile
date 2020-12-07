import 'package:campus_mobile_experimental/core/data_providers/advanced_wayfinding_singleton.dart';
import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/class_schedule_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';
import 'package:campus_mobile_experimental/core/data_providers/events_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/free_food_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/location_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/news_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/notices_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/parking_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/push_notifications_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/shuttle_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/speed_test_service.dart';
import 'package:campus_mobile_experimental/core/data_providers/student_id_data_provider.dart';
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
    create: (_) {
      print("CreateProvider: BottomNavigationBarProvider");
      return BottomNavigationBarProvider();
    },
    lazy: false,
  ),
  ChangeNotifierProvider<SpeedTestService>(
    create: (_) => SpeedTestService(),
  ),
  ChangeNotifierProvider<PushNotificationDataProvider>(
    create: (_) {
      print("CreateProvider: PushNotificationDataProvider");
      return PushNotificationDataProvider();
    },
    lazy: false,
  ),
  ChangeNotifierProvider<EventsDataProvider>(
    create: (_) {
      print("CreateProvider: EventsDataProvider");
      EventsDataProvider _eventsDataProvider = EventsDataProvider();
      _eventsDataProvider.fetchEvents();
      return _eventsDataProvider;
    },
  ),
  ChangeNotifierProvider<WeatherDataProvider>(
    create: (_) {
      print("CreateProvider: WeatherDataProvider");
      WeatherDataProvider _weatherDataProvider = WeatherDataProvider();
      _weatherDataProvider.fetchWeather();
      return _weatherDataProvider;
    },
  ),
  ChangeNotifierProvider<NewsDataProvider>(
    create: (_) {
      print("CreateProvider: NewsDataProvider");
      NewsDataProvider _newsDataProvider = NewsDataProvider();
      _newsDataProvider.fetchNews();
      return _newsDataProvider;
    },
  ),
  StreamProvider<Coordinates>(
    create: (_) {
      print("CreateProvider: Coordinates (LocationDataProvider)");
      return LocationDataProvider().locationStream;
    },
  ),
  ChangeNotifierProvider<CustomAppBar>(
    create: (_) {
      print("CreateProvider: CustomAppBar");
      return CustomAppBar();
    },
  ),
  ChangeNotifierProvider<NoticesDataProvider>(
    create: (_) {
      print("CreateProvider: NoticesDataProvider");
      NoticesDataProvider _noticesDataProvider = NoticesDataProvider();
      _noticesDataProvider.fetchNotices();
      return _noticesDataProvider;
    },
  ),
];
List<SingleChildWidget> dependentServices = [
  ChangeNotifierProxyProvider<Coordinates, DiningDataProvider>(create: (_) {
    print("CreateProvider: DiningDataProvider");
    var diningDataProvider = DiningDataProvider();
    diningDataProvider.fetchDiningLocations();
    return diningDataProvider;
  }, update: (_, coordinates, diningDataProvider) {
    print("UpdateProvider: DiningDataProvider");
    diningDataProvider.coordinates = coordinates;
    diningDataProvider.populateDistances();
    return diningDataProvider;
  }),
  ChangeNotifierProxyProvider<Coordinates, MapsDataProvider>(create: (_) {
    var mapsDataProvider = MapsDataProvider();
    return mapsDataProvider;
  }, update: (_, coordinates, mapsDataProvider) {
    print("UpdateProvider: MapsDataProvider");
    mapsDataProvider.coordinates = coordinates;
    mapsDataProvider.populateDistances();
    return mapsDataProvider;
  }),
  ChangeNotifierProxyProvider<PushNotificationDataProvider, UserDataProvider>(
      create: (_) {
        print("CreateProvider: UserDataProvider");
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
        print("UpdateProvider: UserDataProvider");
        _userDataProvider.pushNotificationDataProvider =
            pushNotificationDataProvider;
        return _userDataProvider;
      }),
  ChangeNotifierProxyProvider<UserDataProvider, CardsDataProvider>(
      create: (_) {
        print("CreateProvider: CardsDataProvider");
        var cardsDataProvider = CardsDataProvider();
        return cardsDataProvider;
      },
      lazy: false,
      update: (_, userDataProvider, cardsDataProvider) {
        print("UpdateProvider: CardsDataProvider");
        cardsDataProvider
          ..loadSavedData().then((value) {
            cardsDataProvider.updateAvailableCards(
                userDataProvider.authenticationModel.ucsdaffiliation);
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
          });
        return cardsDataProvider;
      }),
  ChangeNotifierProxyProvider<UserDataProvider, ClassScheduleDataProvider>(
      create: (_) {
    print("CreateProvider: ClassScheduleDataProvider");
    var classDataProvider = ClassScheduleDataProvider();
    return classDataProvider;
  }, update: (_, userDataProvider, classScheduleDataProvider) {
    print("UpdateProvider: ClassScheduleDataProvider");
    classScheduleDataProvider.userDataProvider = userDataProvider;
    if (userDataProvider.isLoggedIn && !classScheduleDataProvider.isLoading) {
      classScheduleDataProvider.fetchData();
    }
    return classScheduleDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, AdvancedWayfindingSingleton>(
      create: (_) {
    print("CreateProvider: AdvancedWayfindingSingleton");
    var proximityAwarenessSingleton = AdvancedWayfindingSingleton();
    return proximityAwarenessSingleton;
  }, update: (_, userDataProvider, proximityAwarenessSingleton) {
    print("UpdateProvider: AdvancedWayfindingSingleton");
    proximityAwarenessSingleton..userDataProvider = userDataProvider;
    return proximityAwarenessSingleton;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, StudentIdDataProvider>(
      create: (_) {
    print("CreateProvider: StudentIdDataProvider");
    var studentIdDataProvider = StudentIdDataProvider();
    return studentIdDataProvider;
  }, update: (_, userDataProvider, studentIdDataProvider) {
    print("UpdateProvider: StudentIdDataProvider");
    studentIdDataProvider.userDataProvider = userDataProvider;
    //Verify that the user is logged in
    if (userDataProvider.isLoggedIn && !studentIdDataProvider.isLoading) {
      studentIdDataProvider.fetchData();
    }

    return studentIdDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, AvailabilityDataProvider>(
      create: (_) {
    print("CreateProvider: AvailabilityDataProvider");
    var availabilityDataProvider = AvailabilityDataProvider();
    availabilityDataProvider.fetchAvailability();
    return availabilityDataProvider;
  }, update: (_, userDataProvider, availabilityDataProvider) {
    print("UpdateProvider: AvailabilityDataProvider");
    availabilityDataProvider.userDataProvider = userDataProvider;
    return availabilityDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, ShuttleDataProvider>(
      create: (_) {
    print("CreateProvider: ShuttleDataProvider");
    var shuttleDataProvider = ShuttleDataProvider();
    shuttleDataProvider.fetchStops(reloading: false);
    return shuttleDataProvider;
  }, update: (_, userDataProvider, shuttleDataProvider) {
    print("UpdateProvider: ShuttleDataProvider");
    shuttleDataProvider.userDataProvider = userDataProvider;
    return shuttleDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, ParkingDataProvider>(
      create: (_) {
    print("CreateProvider: ParkingDataProvider");
    var parkingDataProvider = ParkingDataProvider();
    return parkingDataProvider;
  }, update: (_, userDataProvider, parkingDataProvider) {
    print("UpdateProvider: ParkingDataProvider");
    parkingDataProvider.userDataProvider = userDataProvider;
    parkingDataProvider.fetchParkingData();
    return parkingDataProvider;
  }),
  ChangeNotifierProxyProvider<UserDataProvider, MessagesDataProvider>(
    create: (_) {
      print("CreateProvider: MessagesDataProvider");
      var messageDataProvider = MessagesDataProvider();
      return messageDataProvider;
    },
    lazy: false,
    update: (_, userDataProvider, messageDataProvider) {
      print("UpdateProvider: MessagesDataProvider");
      messageDataProvider.userDataProvider = userDataProvider;
      messageDataProvider.fetchMessages(true);
      return messageDataProvider;
    },
  ),
  ChangeNotifierProxyProvider<MessagesDataProvider, FreeFoodDataProvider>(
    create: (_) {
      print("CreateProvider: FreeFoodDataProvider");
      var freefoodDataProvider = FreeFoodDataProvider();
      freefoodDataProvider.loadRegisteredEvents();
      return freefoodDataProvider;
    },
    update: (_, messageDataProvider, freefoodDataProvider) {
      print("UpdateProvider: FreeFoodDataProvider");
      freefoodDataProvider.messageDataProvider = messageDataProvider;
      freefoodDataProvider.parseMessages();
      return freefoodDataProvider;
    },
  ),
];
List<SingleChildWidget> uiConsumableProviders = [];
