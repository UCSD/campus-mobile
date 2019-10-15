<<<<<<< HEAD
import 'package:campus_mobile_beta/core/constants/app_constants.dart';
import 'package:campus_mobile_beta/core/models/availability_model.dart';
import 'package:campus_mobile_beta/core/models/events_model.dart';
import 'package:campus_mobile_beta/core/models/links_model.dart';
import 'package:campus_mobile_beta/core/models/news_model.dart';
import 'package:campus_mobile_beta/ui/views/availability/manange_availability_view.dart';
import 'package:campus_mobile_beta/ui/views/baseline/baseline_view.dart';
import 'package:campus_mobile_beta/ui/views/events/event_detail_view.dart';
import 'package:campus_mobile_beta/ui/views/events/events_list.dart';
import 'package:campus_mobile_beta/ui/views/home.dart';
import 'package:campus_mobile_beta/ui/views/links/links_list.dart';
import 'package:campus_mobile_beta/ui/views/map.dart';
import 'package:campus_mobile_beta/ui/views/news/news_detail_view.dart';
import 'package:campus_mobile_beta/ui/views/news/news_list.dart';
import 'package:campus_mobile_beta/ui/views/notifications.dart';
import 'package:campus_mobile_beta/ui/views/profile.dart';
=======
import 'package:campus_mobile/core/constants/app_constants.dart';
import 'package:campus_mobile/core/models/availability_model.dart';
import 'package:campus_mobile/core/models/events_model.dart';
import 'package:campus_mobile/core/models/links_model.dart';
import 'package:campus_mobile/core/models/news_model.dart';
import 'package:campus_mobile/ui/views/availability/manange_availability_view.dart';
import 'package:campus_mobile/ui/views/baseline/baseline_view.dart';
import 'package:campus_mobile/ui/views/events/event_detail_view.dart';
import 'package:campus_mobile/ui/views/events/events_list.dart';
import 'package:campus_mobile/ui/views/home.dart';
import 'package:campus_mobile/ui/views/links/links_list.dart';
import 'package:campus_mobile/ui/views/map.dart';
import 'package:campus_mobile/ui/views/news/news_detail_view.dart';
import 'package:campus_mobile/ui/views/news/news_list.dart';
import 'package:campus_mobile/ui/views/notifications.dart';
import 'package:campus_mobile/ui/views/profile.dart';
>>>>>>> 41519e4... implement links card
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
    }
  }
}
