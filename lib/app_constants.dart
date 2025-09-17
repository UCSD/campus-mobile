import 'package:flutter/material.dart';

class RoutePaths {
  static const String Home = '/';
  static const String BottomNavigationBar = 'bottom_navigation_bar';
  static const String OnboardingInitial = 'onboarding/initial';
  static const String OnboardingLogin = 'onboarding/login';
  static const String Map = 'map/map';
  static const String MapSearch = 'map/map_search';
  static const String MapLocationList = 'map/map_location_list';
  static const String Notifications = 'notifications';
  static const String Profile = 'profile';
  static const String CardsView = 'profile/cards_view';
  static const String NotificationsFilter = 'notifications/filter';
  static const String NewsViewAll = 'news/newslist';
  static const String EventsViewAll = 'events/eventslist';
  static const String EventsAll = 'events/events_view_all';
  static const String NewsDetailView = 'news/news_detail_view';
  static const String EventDetailView = 'events/event_detail_view';
  static const String LinksViewAll = 'links/links_list';
  static const String ClassScheduleViewAll = 'class/classList';
  static const String ManageAvailabilityView = 'availability/manage_locations_view';
  static const String ManageParkingView = 'parking/manage_parking_view';
  static const String ManageShuttleView = 'shuttle/manage_shuttle_view';
  static const String AddShuttleStopsView = 'shuttle/add_shuttle_stops_view';
  static const String DiningViewAllDiningOptions = 'dining/view_all_dining_options';
  static const String DiningOptionDetailView = 'dining/option_detail_view';
  static const String DiningPaymentFilterView = "dining/payment_filter_view";
  // static const String DiningNutritionView = 'dining/dining_nutrition_view';
  static const String Parking = "parking/parking_view";
  static const String SpotTypesView = "parking/spot_types_view";
  static const String ParkingStructureView = "parking/parking_structure_view";
  static const String ParkingLotsView = "parking/parking_lots_view";
  static const String NeighborhoodsView = "parking/neighborhoods_view";
  static const String NeighborhoodsLotsView = "parking/neighborhoods_lot_view";
  static const String AvailabilityDetailedView = "availability/detailed_view";
}

class RouteTitles {
  static const titleMap = {
    'Maps': 'MAP',
    'MapSearch': 'MAP',
    'MapLocationList': 'MAP',
    'Notifications': 'NOTIFICATIONS',
    'Profile': 'PROFILE',
    'profile/cards_view': 'CARDS',
    'notifications/filter': "NOTIFICATIONS FILTER",
    'news/newslist': 'NEWS',
    'news/news_detail_view': 'NEWS',
    'events/eventslist': 'EVENTS',
    'events/event_detail_view': 'EVENTS',
    'class/classList': 'CLASS SCHEDULE',
    'availability/manage_locations_view': 'MANAGE LOCATIONS',
    'shuttle/manage_shuttle_view': 'MANAGE SHUTTLE STOPS',
    'shuttle/add_shuttle_stops_view': 'ADD SHUTTLE STOPS',
    'parking/manage_parking_view': 'MANAGE LOTS',
    'parking/neighborhoods_lot_view': 'MANAGE LOTS',
    'parking/neighborhoods_view': 'MANAGE LOTS',
    'parking/parking_lots_view': 'MANAGE LOTS',
    'parking/parking_structure_view': 'MANAGE LOTS',
    'parking/spot_types_view': 'MANAGE SPOTS',
    'dining/view_all_dining_options': 'DINING',
    'dining/option_detail_view': 'DINING',
    'dining/payment_filter_view': 'PAYMENT FILTERS',
    // 'dining/dining_nutrition_view': 'DINING',
    'availability/detailed_view': 'BUSYNESS',
  };
}

class ParkingDefaults {
  static const defaultLots = [
    "Athena",
    "Gilman",
    "Hopkins",
    "Theatre District",
  ];
  static const defaultSpots = ["S", "B", "A"];
}

class DiningConstants {
  static const payment_filter_types = [
    "Triton Cash",
    "Dining Dollars",
    "Apple/Google Pay",
    "MasterCard/Visa",
    "American Express",
    "Cash",
    "Other",
  ];
}

class ButtonText {
  static const ScanNowFull = 'SCAN YOUR COVID-19 KIT.';
  static const ScanNow = 'SCAN NOW';
  static const SignInFull = 'SCAN YOUR COVID-19 KIT.';
  static const SignIn = 'SIGN IN';
}

class ErrorConstants {
  static const authorizedPostErrors = 'Failed to upload data: ';
  static const authorizedPutErrors = 'Failed to update data: ';
  static const invalidBearerToken = 'Invalid bearer token';
  static const notAcceptable =
      'DioError [DioErrorType.response]: Http status error [406]';
  static const duplicateRecord =
      'DioError [DioErrorType.response]: Http status error [409]';
  static const invalidMedia =
      'DioError [DioErrorType.response]: Http status error [415]';
  static const silentLoginFailed = "Silent login failed";
  static const locationFailed = "Location was not available";
}

class LoginConstants {
  static const silentLoginFailedTitle = 'Oops! You\'re not logged in.';
  static const silentLoginFailedDesc =
      'The system has logged you out (probably by mistake). Go to Profile to log back in.';
  static const loginFailedTitle = 'Sorry, unable to sign you in.';
  static const loginFailedDesc =
      'Be sure you are using the correct credentials; TritonLink login if you are a student, SSO (AD or Active Directory) if you are a Faculty/Staff.';

  static const shuttleMaxTitle = 'Maximum shuttle stops reached';
  static const shuttleMaxDesc =
      'The maximum number of shuttle stops allowed is five. Please remove some stops to add more.';
}

class ParkingConstants {
  static const spotMaxTitle = 'Maximum parking spots reached';
  static const spotMaxDesc =
      'The maximum number of parking spots allowed is three. Please remove some spots to add more.';
  static const lotMaxTitle = 'Maximum parking lots reached';
  static const lotMaxDesc =
      'You have reached the maximum number of lots (10) that can be selected. Please deselect some lots before adding more.';
  static const Map<String, IconData> stringToIconData = {
    'icon - e03e': Icons.accessible,
    'icon - e486': Icons.group,
  };
}

class WifiConstants {
  // Initial State
  static const wifiIssueFailedTitle = 'Could not report issue';
  static const wifiIssueFailedDesc = 'Please run speed test to report issue.';
  // Finished State
  static const wifiIssueSuccessTitle = 'Issue Reported';
  static const wifiIssueSuccessDesc =
      'Thank you for helping improve UCSD wireless. Your test results have been sent to IT Services.';
}

class Plugins {
  static const FrontCamera = 'FRONT CAMERA';
}

class NavigatorConstants {
  static const HomeTab = 0;
  static const MapTab = 1;
  static const NotificationsTab = 2;
  static const ProfileTab = 3;
}

class NotificationsConstants {
  static const statusNoMessages = 'You have no notifications.\n' +
      'It looks like you\'ve unsubscribed from all topics.\n\n' +
      'You can re-subscribe to specific topics via the Notifications Filter.';
  static const statusFetchProblem =
      'There was a problem fetching your messages.\n\n' +
          'Please try again soon.';
  static const statusFetching = 'Loading your notifications, please wait.';
  static const statusNone = '';
  static const statusNoMoreMessages = 'No more messages.';
}

class MessageTypeConstants {
  static const SUCCESS = 1;
  static const INFO = 2;
  static const WARNING = 3;
  static const ERROR = 4;
}

class DataPersistence {
  static const cardStates = 'cardStates';
  static const cardOrder = 'cardOrder';
  static const AuthenticationModel = 'AuthenticationModel';
  static const UserProfileModel = 'UserProfileModel';
}

/// Maps Card IDs to Card titles
class CardTitleConstants {
  static const titleMap = {
    'MyStudentChart': 'MyStudentChart',
    'MyUCSDChart': 'MyUCSDChart',
    'student_id': 'STUDENT ID',
    'speed_test': "TEST WIFI SPEED",
    'employee_id': 'STAFF ID',
    'finals': 'FINALS',
    'schedule': 'CLASSES',
    'shuttle': 'SHUTTLE',
    'dining': 'DINING',
    'availability': 'BUSYNESS',
    'events': 'EVENTS',
    'news': 'NEWS',
    'parking': 'PARKING',
  };
}

class CardMenuOptionConstants {
  static const reloadCard = 'reload card';
  static const hideCard = 'hide card';
}

class ConnectivityConstants {
  static const offlineAlert =
      'It appears you are currently offline. Check network status and try again.';
  static const offlineTitle = 'No Internet';
}
