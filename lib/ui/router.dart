import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:campus_mobile_beta/core/models/availability_model.dart';
import 'package:campus_mobile_beta/core/models/dining_menu_items_model.dart';
import 'package:campus_mobile_beta/core/models/dining_model.dart';
import 'package:campus_mobile_beta/core/models/events_model.dart';
import 'package:campus_mobile_beta/core/models/links_model.dart';
import 'package:campus_mobile_beta/core/models/news_model.dart';
import 'package:campus_mobile_beta/ui/views/availability/manage_availability_view.dart';
import 'package:campus_mobile_beta/ui/views/baseline/baseline_view.dart';
import 'package:campus_mobile_beta/ui/views/dining/dining_detail_view.dart';
import 'package:campus_mobile_beta/ui/views/dining/dining_list.dart';
import 'package:campus_mobile_beta/ui/views/events/event_detail_view.dart';
import 'package:campus_mobile_beta/ui/views/events/events_list.dart';
import 'package:campus_mobile_beta/ui/views/home.dart';
import 'package:campus_mobile_beta/ui/views/links/links_list.dart';
import 'package:campus_mobile_beta/ui/views/map.dart';
import 'package:campus_mobile_beta/ui/views/news/news_detail_view.dart';
import 'package:campus_mobile_beta/ui/views/news/news_list.dart';
import 'package:campus_mobile_beta/ui/views/notifications.dart';
import 'package:campus_mobile_beta/ui/views/profile.dart';
import 'package:campus_mobile_beta/ui/views/dining/nutrtion_facts_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.Home:
        return MaterialPageRoute(builder: (_) => Home());
      case RoutePaths.Map:
        return MaterialPageRoute(builder: (_) => Map());
      case RoutePaths.Notifications:
        return MaterialPageRoute(builder: (_) => Notifications());
      case RoutePaths.Profile:
        return MaterialPageRoute(builder: (_) => Profile());
      case RoutePaths.NewsViewAll:
        NewsModel data = settings.arguments as NewsModel;
        return MaterialPageRoute(builder: (_) => NewsList(data: data));
      case RoutePaths.EventsViewAll:
        List<EventModel> _data = settings.arguments as List<EventModel>;
        return MaterialPageRoute(builder: (_) => EventsList(data: _data));
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
        List<AvailabilityModel> data =
            settings.arguments as List<AvailabilityModel>;
        return MaterialPageRoute(
            builder: (_) => ManageAvailabilityView(data: data));
      case RoutePaths.LinksViewAll:
        List<LinksModel> data = settings.arguments as List<LinksModel>;
        return MaterialPageRoute(builder: (_) => LinksList(data: data));
      case RoutePaths.DiningViewAll:
        List<DiningModel> data = settings.arguments as List<DiningModel>;
        return MaterialPageRoute(builder: (_) => DiningList(data: data));
      case RoutePaths.DiningDetailView:
        DiningModel data = settings.arguments as DiningModel;
        return MaterialPageRoute(builder: (_) => DiningDetailView(data: data));
      case RoutePaths.DiningNutritionView:
        MenuItem data = settings.arguments as MenuItem;
        return MaterialPageRoute(
            builder: (_) => NutritionFactsView(data: data));
    }
  }
}
