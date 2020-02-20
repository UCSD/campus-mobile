import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu_items_model.dart';
import 'package:campus_mobile_experimental/core/models/dining_model.dart';
import 'package:campus_mobile_experimental/core/models/events_model.dart';
import 'package:campus_mobile_experimental/core/models/news_model.dart';
import 'package:campus_mobile_experimental/ui/cards/dining/dining_list.dart';
import 'package:campus_mobile_experimental/ui/views/availability/manage_availability_view.dart';
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
import 'package:campus_mobile_experimental/ui/views/notifications/notifications.dart';
import 'package:campus_mobile_experimental/ui/views/parking/manage_parking_view.dart';
import 'package:campus_mobile_experimental/ui/views/profile/cards_view.dart';
import 'package:campus_mobile_experimental/ui/views/profile/profile.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/special_events_detail_view.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/special_events_filter_view.dart';
import 'package:campus_mobile_experimental/ui/views/surf/surf_report_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.Home:
        return MaterialPageRoute(
            builder: (_) => Home(),
            settings: RouteSettings(name: RoutePaths.Home));
      case RoutePaths.SpecialEventsDetailView:
        return MaterialPageRoute(
            builder: (_) => SpecialEventsViewModel(),
            settings: RouteSettings(name: RoutePaths.SpecialEventsDetailView));
      case RoutePaths.SpecialEventsFilterView:
        return MaterialPageRoute(
            builder: (_) => SpecialEventsFilterView(),
            settings: RouteSettings(name: RoutePaths.SpecialEventsFilterView));
      case RoutePaths.Map:
        return MaterialPageRoute(
            builder: (_) => prefix0.Maps(),
            settings: RouteSettings(name: RoutePaths.Map));
      case RoutePaths.MapSearch:
        return MaterialPageRoute(builder: (_) => MapSearchView());
      case RoutePaths.Notifications:
        return MaterialPageRoute(
            builder: (_) => Notifications(),
            settings: RouteSettings(name: RoutePaths.Notifications));
      case RoutePaths.Profile:
        return MaterialPageRoute(
            builder: (_) => Profile(),
            settings: RouteSettings(name: RoutePaths.Profile));
      case RoutePaths.NewsViewAll:
        NewsModel data = settings.arguments as NewsModel;
        return MaterialPageRoute(
            builder: (_) => NewsList(),
            settings: RouteSettings(name: RoutePaths.NewsViewAll));
      case RoutePaths.EventsViewAll:
        return MaterialPageRoute(
            builder: (context) => EventsList(),
            settings: RouteSettings(name: RoutePaths.EventsViewAll));
      case RoutePaths.NewsDetailView:
        Item newsItem = settings.arguments as Item;
        return MaterialPageRoute(
            builder: (_) => NewsDetailView(data: newsItem),
            settings: RouteSettings(name: RoutePaths.NewsDetailView));
      case RoutePaths.EventDetailView:
        EventModel data = settings.arguments as EventModel;
        return MaterialPageRoute(
            builder: (_) => EventDetailView(data: data),
            settings: RouteSettings(name: RoutePaths.EventDetailView));
      case RoutePaths.ManageAvailabilityView:
        return MaterialPageRoute(
            builder: (_) => ManageAvailabilityView(),
            settings: RouteSettings(name: RoutePaths.ManageAvailabilityView));
      case RoutePaths.LinksViewAll:
        return MaterialPageRoute(
            builder: (_) => LinksList(),
            settings: RouteSettings(name: RoutePaths.LinksViewAll));
      case RoutePaths.DiningViewAll:
        return MaterialPageRoute(
            builder: (_) => DiningList(),
            settings: RouteSettings(name: RoutePaths.DiningViewAll));
      case RoutePaths.DiningDetailView:
        DiningModel data = settings.arguments as DiningModel;
        return MaterialPageRoute(
            builder: (_) => DiningDetailView(data: data),
            settings: RouteSettings(name: RoutePaths.DiningDetailView));
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
                ),
            settings: RouteSettings(name: RoutePaths.DiningNutritionView));
      case RoutePaths.SurfView:
        return MaterialPageRoute(
            builder: (_) => SurfView(),
            settings: RouteSettings(name: RoutePaths.SurfView));
      case RoutePaths.ManageParkingView:
        return MaterialPageRoute(
            builder: (_) => ManageParkingView(),
            settings: RouteSettings(name: RoutePaths.ManageParkingView));
      case RoutePaths.CardsView:
        return MaterialPageRoute(
            builder: (_) => CardsView(),
            settings: RouteSettings(name: RoutePaths.CardsView));
      case RoutePaths.ClassScheduleViewAll:
        return MaterialPageRoute(
            builder: (_) => ClassList(),
            settings: RouteSettings(name: RoutePaths.ClassScheduleViewAll));
      default:
        return MaterialPageRoute(
            builder: (_) => Home(),
            settings: RouteSettings(name: RoutePaths.Home));
    }
  }
}
