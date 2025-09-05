import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_constants.dart';
import 'ui/home/home.dart';
import 'ui/map/map.dart' as prefix0;
import 'ui/notifications/notifications_list_view.dart';
import 'ui/profile/profile.dart';
import 'ui/events/events_card_list.dart';
import 'ui/dining/dining_list.dart';
import 'ui/news/news_list.dart';
import 'ui/news/news_detail_view.dart';
import 'ui/events/events_detail_view.dart';
import 'ui/classes/classes_list.dart';
import 'ui/availability/manage_availability_view.dart';
import 'ui/availability/availability_detail_view.dart';
import 'ui/shuttle/manage_shuttle_view.dart';
import 'ui/shuttle/add_shuttle_stops_view.dart';
import 'ui/parking/manage_parking_view.dart';
import 'ui/parking/spot_types_view.dart';
import 'ui/parking/parking_structure_view.dart';
import 'ui/parking/neighborhoods_view.dart';
import 'ui/parking/neighborhood_lot_view.dart';
import 'ui/profile/cards.dart';
import 'ui/notifications/notifications_filter.dart';
import 'ui/dining/dining_detail_view.dart';
import 'ui/dining/nutrition_facts_view.dart';
import 'core/models/news.dart';
import 'core/models/events.dart';
import 'core/models/dining.dart';
import 'core/models/dining_menu.dart';
import 'core/models/availability.dart';
import 'ui/navigator/top.dart';

Route<dynamic> generateAppRoute(RouteSettings settings, {BuildContext? context}) {
  final ctx = context ?? (settings.arguments is BuildContext ? settings.arguments as BuildContext : null);
  switch (settings.name) {
    case RoutePaths.Home:
      return MaterialPageRoute(builder: (_) => Home(), settings: settings);
    case RoutePaths.Map:
      return MaterialPageRoute(builder: (_) => prefix0.Maps(), settings: settings);
    case RoutePaths.Notifications:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return NotificationsListView();
      }, settings: settings);
    case RoutePaths.Profile:
      return MaterialPageRoute(builder: (_) => Profile(), settings: settings);
    case RoutePaths.NewsViewAll:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return NewsList();
      }, settings: settings);
    case RoutePaths.EventsViewAll:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return EventsCardList();
      }, settings: settings);
    case RoutePaths.NewsDetailView:
      Item newsItem = settings.arguments as Item;
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return NewsDetailView(data: newsItem);
      }, settings: settings);
    case RoutePaths.EventDetailView:
      EventModel data = settings.arguments as EventModel;
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return EventDetailView(data: data);
      }, settings: settings);
    case RoutePaths.DiningViewAll:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return DiningList();
      }, settings: settings);
    case RoutePaths.DiningDetailView:
      DiningModel data = settings.arguments as DiningModel;
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return DiningDetailView(data: data);
      }, settings: settings);
    case RoutePaths.DiningNutritionView:
      Map<String, Object?> arguments = settings.arguments as Map<String, Object?>;
      DiningMenuItem data = arguments['data'] as DiningMenuItem;
      String? disclaimer = arguments['disclaimer'] as String?;
      String? disclaimerEmail = arguments['disclaimerEmail'] as String?;
      return MaterialPageRoute(
        builder: (_) => NutritionFactsView(
          data: data,
          disclaimer: disclaimer,
          disclaimerEmail: disclaimerEmail,
        ),
        settings: settings,
      );
    case RoutePaths.ClassScheduleViewAll:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return ClassList();
      }, settings: settings);
    case RoutePaths.ManageAvailabilityView:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return ManageAvailabilityView();
      }, settings: settings);
    case RoutePaths.AvailabilityDetailedView:
      SubLocations subLocation = settings.arguments as SubLocations;
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return AvailabilityDetailedView(subLocation: subLocation);
      }, settings: settings);
    case RoutePaths.ManageParkingView:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return ManageParkingView();
      }, settings: settings);
    case RoutePaths.SpotTypesView:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return SpotTypesView();
      }, settings: settings);
    case RoutePaths.ParkingStructureView:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name, done: true);
        return ParkingStructureView();
      }, settings: settings);
    case RoutePaths.NeighborhoodsView:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name, done: true);
        return NeighborhoodsView();
      }, settings: settings);
    case RoutePaths.NeighborhoodsLotsView:
      List<String> data = settings.arguments as List<String>;
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name, done: true);
        return NeighborhoodLotsView(data);
      }, settings: settings);
    case RoutePaths.ManageShuttleView:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return ManageShuttleView();
      }, settings: settings);
    case RoutePaths.AddShuttleStopsView:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return AddShuttleStopsView();
      }, settings: settings);
    case RoutePaths.CardsView:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return CardsView();
      }, settings: settings);
    case RoutePaths.NotificationsFilter:
      return MaterialPageRoute(builder: (_) {
        if (ctx != null) Provider.of<CustomAppBar>(ctx).changeTitle(settings.name);
        return NotificationsFilterView();
      }, settings: settings);
    default:
      return MaterialPageRoute(builder: (_) => Home(), settings: settings);
  }
}

