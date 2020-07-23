import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/ui/availability/manage_availability_view.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_list.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_detail_view.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_list.dart';
import 'package:campus_mobile_experimental/ui/dining/nutrition_facts_view.dart';
import 'package:campus_mobile_experimental/ui/events/events_detail_view.dart';
import 'package:campus_mobile_experimental/ui/events/events_list.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/map/map_search_view.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/news/news_detail_view.dart';
import 'package:campus_mobile_experimental/ui/news/news_list.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_list_view.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_login.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_screen.dart';
import 'package:campus_mobile_experimental/ui/profile/cards.dart';
import 'package:campus_mobile_experimental/ui/profile/notifications.dart';
import 'package:campus_mobile_experimental/ui/profile/profile.dart';
import 'package:campus_mobile_experimental/ui/scanner/scanner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.BottomNavigationBar:
        return MaterialPageRoute(builder: (_) => BottomTabBar());
      case RoutePaths.Onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case RoutePaths.OnboardingLogin:
        return MaterialPageRoute(builder: (_) => OnboardingLogin());
      case RoutePaths.Home:
        return MaterialPageRoute(builder: (_) => Home());
      case RoutePaths.Map:
        return MaterialPageRoute(builder: (_) => prefix0.Maps());
      case RoutePaths.MapSearch:
        return MaterialPageRoute(builder: (_) => MapSearchView());
      case RoutePaths.Notifications:
        return MaterialPageRoute(builder: (_) => NotificationsListView());
      case RoutePaths.Profile:
        return MaterialPageRoute(builder: (_) => Profile());
      case RoutePaths.NewsViewAll:
        NewsModel data = settings.arguments as NewsModel;
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return NewsList();
        });
      case RoutePaths.EventsViewAll:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return EventsList();
        });
      case RoutePaths.NewsDetailView:
        Item newsItem = settings.arguments as Item;
        return MaterialPageRoute(
            builder: (_) => NewsDetailView(data: newsItem));
      case RoutePaths.EventDetailView:
        EventModel data = settings.arguments as EventModel;
        return MaterialPageRoute(builder: (_) => EventDetailView(data: data));
      case RoutePaths.ManageAvailabilityView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return ManageAvailabilityView();
        });
      case RoutePaths.DiningViewAll:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return DiningList();
        });
      case RoutePaths.DiningDetailView:
        DiningModel data = settings.arguments as DiningModel;
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return DiningDetailView(data: data);
        });
      case RoutePaths.DiningNutritionView:
        Map<String, Object> arguments = settings.arguments;
        MenuItem data = arguments['data'] as MenuItem;
        String disclaimer = arguments['disclaimer'] as String;
        String disclaimerEmail = arguments['disclaimerEmail'] as String;
        return MaterialPageRoute(
            builder: (_) => NutritionFactsView(
                  data: data,
                  disclaimer: disclaimer,
                  disclaimerEmail: disclaimerEmail,
                ));
      case RoutePaths.CardsView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return CardsView();
        });
      case RoutePaths.NotificationsSettingsView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return NotificationsSettingsView();
        });
      case RoutePaths.ScannerView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return ScannerView();
        });
      case RoutePaths.ClassScheduleViewAll:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return ClassList();
        });
    }
  }
}

class RoutePaths {
  static const String Home = '/';
  static const String BottomNavigationBar = 'bottom_navigation_bar';
  static const String Onboarding = 'onboarding';
  static const String OnboardingLogin = 'onboarding/login';
  static const String Map = 'map/map';
  static const String MapSearch = 'map/map_search';
  static const String MapLocationList = 'map/map_location_list';
  static const String Notifications = 'notifications';
  static const String Profile = 'profile';
  static const String CardsView = 'profile/cards_view';
  static const String NotificationsSettingsView =
      'notifications/notifications_settings';

  static const String NewsViewAll = 'news/newslist';
  static const String BaseLineView = 'baseline/baselineview';
  static const String EventsViewAll = 'events/eventslist';
  static const String NewsDetailView = 'news/news_detail_view';
  static const String EventDetailView = 'events/event_detail_view';
  static const String LinksViewAll = 'links/links_list';
  static const String ClassScheduleViewAll = 'class/classList';
  static const String ManageAvailabilityView =
      'availability/manage_locations_view';
  static const String ManageParkingView = 'parking/manage_parking_view';
  static const String DiningViewAll = 'dining/dining_list_view';
  static const String DiningDetailView = 'dining/dining_detail_view';
  static const String DiningNutritionView = 'dining/dining_nutrition_view';
  static const String SurfView = 'surfing/surf_view';
  static const String SpecialEventsListView =
      'special_events/special_events_list_view';
  static const String SpecialEventsFilterView =
      'special_events/special_events_filter_view';
  static const String SpecialEventsDetailView =
      'special_events/special_events_detail_view';
  static const String ScannerView = 'scanner/scanner_view';
}

class RouteTitles {
  static const titleMap = {
    'Maps': 'Maps',
    'MapSearch': 'Maps',
    'MapLocationList': 'Maps',
    'Notifications': 'Notifications',
    'Profile': 'Profile',
    'profile/cards_view': 'Cards',
    'notifications/notifications_settings': "Notification Settings",
    'news/newslist': 'News',
    'news/news_detail_view': 'News',
    'events/eventslist': 'Events',
    'events/event_detail_view': 'Events',
    'class/classList': 'Class Schedule',
    'availability/manage_locations_view': 'Manage Locations',
    'parking/manage_parking_view': 'Parking',
    'dining/dining_list_view': 'Dining',
    'dining/dining_detail_view': 'Dining',
    'dining/dining_nutrition_view': 'Dining',
    'special_events/special_events_list_view': 'Special Events',
    'special_events/special_events_filter_view': 'Special Events',
    'special_events/special_events_detail_view': 'Special Events',
    'scanner/scanner_view': 'Scanner',
  };
}

class NavigatorConstants {
  static const HomeTab = 0;
  static const MapTab = 1;
  static const NotificationsTab = 2;
  static const ProfileTab = 3;
}
