import 'package:campus_mobile_experimental/app_constants.dart';
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
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_affiliations.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_initial_screen.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_login.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_screen.dart';
import 'package:campus_mobile_experimental/ui/parking/manage_parking_view.dart';
import 'package:campus_mobile_experimental/ui/parking/spot_types_view.dart';
import 'package:campus_mobile_experimental/ui/profile/cards.dart';
import 'package:campus_mobile_experimental/ui/profile/notifications.dart';
import 'package:campus_mobile_experimental/ui/profile/profile.dart';
import 'package:campus_mobile_experimental/ui/scanner/native_scanner_view.dart';
import 'package:campus_mobile_experimental/ui/shuttle/add_shuttle_stops_view.dart';
import 'package:campus_mobile_experimental/ui/shuttle/manage_shuttle_view.dart';
import 'package:campus_mobile_experimental/ui/wayfinding/beacon_view.dart';
import 'package:campus_mobile_experimental/ui/wayfinding/wayfinding_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.BottomNavigationBar:
        return MaterialPageRoute(builder: (_) => BottomTabBar());
      case RoutePaths.OnboardingInitial:
        return MaterialPageRoute(builder: (_) => OnboardingInitial());
      case RoutePaths.Onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case RoutePaths.OnboardingAffiliations:
        return MaterialPageRoute(builder: (_) => OnboardingAffiliations());
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
      case RoutePaths.ManageParkingView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return ManageParkingView();
        });
      case RoutePaths.ManageShuttleView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return ManageShuttleView();
        });
      case RoutePaths.AddShuttleStopsView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return AddShuttleStopsView();
        });
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
      case RoutePaths.BluetoothPermissionsView:
        return MaterialPageRoute(
            builder: (_) => AdvancedWayfindingPermission());
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return NotificationsListView();
        });
      case RoutePaths.ClassScheduleViewAll:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return ClassList();
        });
      case RoutePaths.SpotTypesView:
        return MaterialPageRoute(builder: (_) {
          Provider.of<CustomAppBar>(_).changeTitle(settings.name);
          return SpotTypesView();
        });
      case RoutePaths.BeaconView:
        return MaterialPageRoute(builder: (_) => BeaconView());
      case RoutePaths.ScanditScanner:
        return MaterialPageRoute(builder: (_) => ScanditScanner());
    }
  }
}
