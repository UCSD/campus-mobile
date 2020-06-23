import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu_items_model.dart';
import 'package:campus_mobile_experimental/core/models/dining_model.dart';
import 'package:campus_mobile_experimental/core/models/events_model.dart';
import 'package:campus_mobile_experimental/core/models/news_model.dart';
import 'package:campus_mobile_experimental/core/navigation/bottom_tab_bar/bottom_navigation_bar_model.dart';
import 'package:campus_mobile_experimental/ui/cards/dining/dining_list.dart';
import 'package:campus_mobile_experimental/ui/views/availability/manage_availability_view.dart';
import 'package:campus_mobile_experimental/ui/views/baseline/baseline_view.dart';
import 'package:campus_mobile_experimental/ui/views/class_schedule/class_list.dart';
import 'package:campus_mobile_experimental/ui/views/dining/dining_detail_view.dart';
import 'package:campus_mobile_experimental/ui/views/dining/nutrition_facts_view.dart';
import 'package:campus_mobile_experimental/ui/views/events/event_detail_view.dart';
import 'package:campus_mobile_experimental/ui/views/events/events_list.dart';
import 'package:campus_mobile_experimental/ui/views/home/home.dart';
import 'package:campus_mobile_experimental/ui/views/links/links_list.dart';
import 'package:campus_mobile_experimental/ui/views/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/views/map/map_search_view.dart';
import 'package:campus_mobile_experimental/ui/views/news/news_detail_view.dart';
import 'package:campus_mobile_experimental/ui/views/news/news_list.dart';
import 'package:campus_mobile_experimental/ui/views/notifications/notifications_list_view.dart';
import 'package:campus_mobile_experimental/ui/views/notifications/notifications_settings.dart';
import 'package:campus_mobile_experimental/ui/views/onboarding/onboarding_login.dart';
import 'package:campus_mobile_experimental/ui/views/onboarding/onboarding_screen.dart';
import 'package:campus_mobile_experimental/ui/views/parking/manage_parking_view.dart';
import 'package:campus_mobile_experimental/ui/views/parking/parking_view.dart';
import 'package:campus_mobile_experimental/ui/views/profile/cards_view.dart';
import 'package:campus_mobile_experimental/ui/views/profile/profile.dart';
import 'package:campus_mobile_experimental/ui/views/scanner/scanner_view.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/special_event_detail_view.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/special_events_filter_view.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/special_events_list_view.dart';
import 'package:campus_mobile_experimental/ui/views/surf/surf_report_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'bottom_tab_bar/bottom_navigation_bar_model.dart';

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
      case RoutePaths.SpecialEventsListView:
        return MaterialPageRoute(builder: (_) => SpecialEventsListView());
      case RoutePaths.SpecialEventsFilterView:
        return MaterialPageRoute(builder: (_) => SpecialEventsFilterView());
      case RoutePaths.SpecialEventsDetailView:
        String uid = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => SpecialEventsDetailView(argument: uid));
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
        return MaterialPageRoute(builder: (_) => NewsList());
      case RoutePaths.EventsViewAll:
        return MaterialPageRoute(builder: (context) => EventsList());
      case RoutePaths.BaseLineView:
        return MaterialPageRoute(builder: (_) => BaselineView());
      case RoutePaths.NewsDetailView:
        Item newsItem = settings.arguments as Item;
        return MaterialPageRoute(
            builder: (_) => NewsDetailView(data: newsItem));
      case RoutePaths.EventDetailView:
        EventModel data = settings.arguments as EventModel;
        return MaterialPageRoute(builder: (_) => EventDetailView(data: data));
      case RoutePaths.ManageAvailabilityView:
        return MaterialPageRoute(builder: (_) => ManageAvailabilityView());
      case RoutePaths.LinksViewAll:
        return MaterialPageRoute(builder: (_) => LinksList());
      case RoutePaths.DiningViewAll:
        return MaterialPageRoute(builder: (_) => DiningList());
      case RoutePaths.DiningDetailView:
        DiningModel data = settings.arguments as DiningModel;
        return MaterialPageRoute(builder: (_) => DiningDetailView(data: data));
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
      case RoutePaths.SurfView:
        return MaterialPageRoute(builder: (_) => SurfView());
      case RoutePaths.ManageParkingView:
        return MaterialPageRoute(builder: (_) => ManageParkingView());
      case RoutePaths.CardsView:
        return MaterialPageRoute(builder: (_) => CardsView());
      case RoutePaths.NotificationsSettingsView:
        return MaterialPageRoute(builder: (_) => NotificationsSettingsView());
      case RoutePaths.ScannerView:
        return MaterialPageRoute(builder: (_) => ScannerView());
      case RoutePaths.ClassScheduleViewAll:
        return MaterialPageRoute(builder: (_) => ClassList());
      case RoutePaths.Parking:
        return MaterialPageRoute(
            builder: (_) => ParkingWebViewContainer('https://google.com'));
    }
  }
}
