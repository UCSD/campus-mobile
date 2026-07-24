import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_detail_view.dart';
import 'package:campus_mobile_experimental/ui/availability/manage_availability_view.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_list.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_detail_view.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_filter_view.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_list.dart';
import 'package:campus_mobile_experimental/ui/events/events_detail_view.dart';
import 'package:campus_mobile_experimental/ui/events/events_card_list.dart';
import 'package:campus_mobile_experimental/ui/events/events_view_all.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/map/map_search_view.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/citation_web_view.dart';
import 'package:campus_mobile_experimental/ui/news/news_detail_view.dart';
import 'package:campus_mobile_experimental/ui/news/news_list.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_list_view.dart';
import 'package:campus_mobile_experimental/ui/notifications/notifications_filter.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_slides.dart';
import 'package:campus_mobile_experimental/ui/onboarding/onboarding_login.dart';
import 'package:campus_mobile_experimental/ui/parking/manage_parking_view.dart';
import 'package:campus_mobile_experimental/ui/parking/neighborhood_lot_view.dart';
import 'package:campus_mobile_experimental/ui/parking/neighborhoods_view.dart';
import 'package:campus_mobile_experimental/ui/parking/parking_structure_view.dart';
import 'package:campus_mobile_experimental/ui/parking/spot_types_view.dart';
import 'package:campus_mobile_experimental/ui/profile/cards.dart';
import 'package:campus_mobile_experimental/ui/profile/profile.dart';
import 'package:campus_mobile_experimental/ui/shuttle/add_shuttle_stops_view.dart';
import 'package:campus_mobile_experimental/ui/shuttle/manage_shuttle_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.BOTTOM_NAVIGATION_BAR:
        return MaterialPageRoute(builder: (_) => BottomTabBar());
      case RoutePaths.ONBOARDING_INITIAL:
        return MaterialPageRoute(builder: (_) => OnboardingSlides());
      case RoutePaths.ONBOARDING_LOGIN:
        return MaterialPageRoute(builder: (_) => OnboardingLogin());
      case RoutePaths.HOME:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(null);
          return Home();
        });
      case RoutePaths.MAP:
        return MaterialPageRoute(builder: (_) => prefix0.Maps());
      case RoutePaths.MAP_SEARCH:
        return MaterialPageRoute(builder: (_) => MapSearchView());
      case RoutePaths.NOTIFICATIONS:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return NotificationsListView();
        });
      case RoutePaths.PROFILE:
        return MaterialPageRoute(builder: (_) => Profile());
      case RoutePaths.NEWS_VIEW_ALL:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return NewsList();
        });
      case RoutePaths.EVENTS_VIEW_ALL:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return EventsCardList();
        });
      case RoutePaths.NEWS_DETAIL_VIEW:
        Item newsItem = settings.arguments as Item;
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return NewsDetailView(data: newsItem);
        });
      case RoutePaths.TGPT_CITATION_WEB:
        final String citationUrl = settings.arguments as String;
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return CitationWebView(initialUrl: citationUrl);
        });
      case RoutePaths.EVENT_DETAIL_VIEW:
        EventModel data = settings.arguments as EventModel;
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return EventDetailView(data: data);
        });
      case RoutePaths.EVENTS_ALL:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return EventsAll();
        });
      case RoutePaths.MANAGE_AVAILABILITY_VIEW:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return ManageAvailabilityView();
        });
      case RoutePaths.AVAILABILITY_DETAILED_VIEW:
        SubLocations subLocation = settings.arguments as SubLocations;
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return AvailabilityDetailedView(subLocation: subLocation);
        });
      case RoutePaths.DINING_VIEW_ALL_DINING_OPTIONS:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return DiningList();
        });
      case RoutePaths.DINING_OPTION_DETAIL_VIEW:
        DiningModel data = settings.arguments as DiningModel;
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return DiningDetailView(data: data);
        });
      case RoutePaths.DINING_PAYMENT_FILTER_VIEW:
        // Don't Change the app bar title for this view
        return MaterialPageRoute(builder: (_) => DiningFilterView());
      // case RoutePaths.DiningNutritionView:
      //   Map<String, Object?> arguments =
      //       settings.arguments as Map<String, Object?>;
      //   DiningMenuItem data = arguments['data'] as DiningMenuItem;
      //   String? disclaimer = arguments['disclaimer'] as String?;
      //   String? disclaimerEmail = arguments['disclaimerEmail'] as String?;
      //   return MaterialPageRoute(
      //       builder: (_) => NutritionFactsView(
      //             data: data,
      //             disclaimer: disclaimer,
      //             disclaimerEmail: disclaimerEmail,
      //           ));
      case RoutePaths.MANAGE_PARKING_VIEW:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return ManageParkingView();
        });
      case RoutePaths.SPOT_TYPES_VIEW:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return SpotTypesView();
        });
      case RoutePaths.MANAGE_SHUTTLE_VIEW:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return ManageShuttleView();
        });
      case RoutePaths.ADD_SHUTTLE_STOPS_VIEW:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return AddShuttleStopsView();
        });
      case RoutePaths.CARDS_VIEW:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return CardsView();
        });
      case RoutePaths.NOTIFICATIONS_FILTER:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return NotificationsFilterView();
        });
      case RoutePaths.CLASS_SCHEDULE_VIEW_ALL:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name);
          return ClassList();
        });
      case RoutePaths.PARKING_STRUCTURE_VIEW:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name, done: true);
          return ParkingStructureView();
        });
      case RoutePaths.NEIGHBORHOODS_VIEW:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name, done: true);
          return NeighborhoodsView();
        });
      case RoutePaths.NEIGHBORHOODS_LOTS_VIEW:
        List<String> data = settings.arguments as List<String>;
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(settings.name, done: true);
          return NeighborhoodLotsView(data);
        });
      default:
        return MaterialPageRoute(builder: (context) {
          Provider.of<CustomAppBar>(context).changeTitle(null);
          return Home();
        });
    }
  }
}
