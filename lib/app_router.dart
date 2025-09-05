import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/dining_menu.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/ui/availability/availability_detail_view.dart';
import 'package:campus_mobile_experimental/ui/availability/manage_availability_view.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_list.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_detail_view.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_list.dart';
import 'package:campus_mobile_experimental/ui/dining/nutrition_facts_view.dart';
import 'package:campus_mobile_experimental/ui/events/events_detail_view.dart';
import 'package:campus_mobile_experimental/ui/events/events_card_list.dart';
import 'package:campus_mobile_experimental/ui/events/events_view_all.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/map/map_search_view.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
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
import 'app_route_generator.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return generateAppRoute(settings);
  }
}
