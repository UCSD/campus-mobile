import 'package:campus_mobile/core/models/events_model.dart';
import 'package:campus_mobile/core/models/news_model.dart';
import 'package:campus_mobile/ui/views/news/news_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:campus_mobile/core/constants/app_constants.dart';
import 'package:campus_mobile/ui/views/home.dart';
import 'package:campus_mobile/ui/views/map.dart';
import 'package:campus_mobile/ui/views/notifications.dart';
import 'package:campus_mobile/ui/views/profile.dart';
import 'package:campus_mobile/ui/views/baseline/baseline_view.dart';
import 'package:campus_mobile/ui/views/events/events_list.dart';
import 'package:campus_mobile/ui/views/news/news_detail_view.dart';

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
        Future<NewsModel> _data = settings.arguments as Future<NewsModel>;
        return MaterialPageRoute(builder: (_) => NewsList(data: _data));
      case RoutePaths.EventsViewAll:
        Future<List<EventModel>> _data =
            settings.arguments as Future<List<EventModel>>;
        return MaterialPageRoute(builder: (_) => EventsList(data: _data));
      case RoutePaths.BaseLineView:
        return MaterialPageRoute(builder: (_) => BaselineView());
      case RoutePaths.NewsDetailView:
        Item newsItem = settings.arguments as Item;
        return MaterialPageRoute(
            builder: (_) => NewsDetailView(data: newsItem));
    }
  }
}
