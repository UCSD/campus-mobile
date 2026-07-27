import 'package:flutter/material.dart';

class RoutePaths {
  static const String HOME = '/';
  static const String BOTTOM_NAVIGATION_BAR = 'bottom_navigation_bar';
  static const String ONBOARDING_INITIAL = 'onboarding/initial';
  static const String ONBOARDING_LOGIN = 'onboarding/login';
  static const String MAP = 'map/map';
  static const String MAP_SEARCH = 'map/map_search';
  static const String MAP_LOCATION_LIST = 'map/map_location_list';
  static const String NOTIFICATIONS = 'notifications';
  static const String PROFILE = 'profile';
  static const String CARDS_VIEW = 'profile/cards_view';
  static const String NOTIFICATIONS_FILTER = 'notifications/filter';
  static const String NEWS_VIEW_ALL = 'news/newslist';
  static const String EVENTS_VIEW_ALL = 'events/eventslist';
  static const String EVENTS_ALL = 'events/events_view_all';
  static const String NEWS_DETAIL_VIEW = 'news/news_detail_view';
  static const String EVENT_DETAIL_VIEW = 'events/event_detail_view';
  static const String LINKS_VIEW_ALL = 'links/links_list';
  static const String CLASS_SCHEDULE_VIEW_ALL = 'class/classList';
  static const String MANAGE_AVAILABILITY_VIEW = 'availability/manage_locations_view';
  static const String MANAGE_PARKING_VIEW = 'parking/manage_parking_view';
  static const String MANAGE_SHUTTLE_VIEW = 'shuttle/manage_shuttle_view';
  static const String ADD_SHUTTLE_STOPS_VIEW = 'shuttle/add_shuttle_stops_view';
  static const String DINING_VIEW_ALL_DINING_OPTIONS = 'dining/view_all_dining_options';
  static const String DINING_OPTION_DETAIL_VIEW = 'dining/option_detail_view';
  static const String DINING_PAYMENT_FILTER_VIEW = "dining/payment_filter_view";
  // static const String DINING_NUTRITION_VIEW = 'dining/dining_nutrition_view';
  static const String PARKING = "parking/parking_view";
  static const String SPOT_TYPES_VIEW = "parking/spot_types_view";
  static const String PARKING_STRUCTURE_VIEW = "parking/parking_structure_view";
  static const String PARKING_LOTS_VIEW = "parking/parking_lots_view";
  static const String NEIGHBORHOODS_VIEW = "parking/neighborhoods_view";
  static const String NEIGHBORHOODS_LOTS_VIEW = "parking/neighborhoods_lot_view";
  static const String AVAILABILITY_DETAILED_VIEW = "availability/detailed_view";
  static const String TGPT_CITATION_WEB = 'ai_assistant/citation_web';
}

class RouteTitles {
  static const TITLE_MAP = {
    'Maps': 'MAP',
    'AI Assistant': 'AI ASSISTANT',
    'ai_assistant/citation_web': 'CITATION',
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
  static const DEFAULT_LOTS = ["Athena", "Gilman", "Hopkins", "Theatre District", "South", "First Ave"];
  static const DEFAULT_SPOTS = ["S", "B", "A"];
}

class DiningConstants {
  static const PAYMENT_FILTER_TYPES = [
    "Triton Cash",
    "Dining Dollars",
    "Apple/Google Pay",
    "MasterCard/Visa",
    "American Express",
    "Cash",
    "Other",
  ];
}

class ErrorConstants {
  /// TritonGPT chat / streaming failures (user-facing; no stack traces).
  static const TRITONGPT_UNAVAILABLE = 'Unable to reach TritonGPT right now. Please try again later.';
  static const TRITONGPT_NOT_FOUND = 'TritonGPT could not be reached. Please try again later.';
  static const TRITONGPT_SERVER_ERROR = 'TritonGPT is temporarily unavailable. Please try again later.';
  static const TRITONGPT_BAD_REQUEST = 'Your message could not be processed. Please try again.';

  static const AUTHORIZED_POST_ERRORS = 'Failed to upload data: ';
  static const AUTHORIZED_PUT_ERRORS = 'Failed to update data: ';
  static const INVALID_BEARER_TOKEN = 'Invalid bearer token';
  static const NOT_ACCEPTABLE = 'DioError [DioErrorType.response]: Http status error [406]';
  static const DUPLICATE_RECORD = 'DioError [DioErrorType.response]: Http status error [409]';
  static const INVALID_MEDIA = 'DioError [DioErrorType.response]: Http status error [415]';
  static const SILENT_LOGIN_FAILED = "Silent login failed";
  static const LOCATION_FAILED = "Location was not available";
}

class LoginConstants {
  static const SILENT_LOGIN_FAILED_TITLE = 'Oops! You\'re not logged in.';
  static const SILENT_LOGIN_FAILED_DESC =
      'The system has logged you out (probably by mistake). Go to Profile to log back in.';
  static const LOGIN_FAILED_TITLE = 'Sorry, unable to sign you in.';
  static const LOGIN_FAILED_DESC =
      'Be sure you are using the correct credentials; TritonLink login if you are a student, SSO (AD or Active Directory) if you are a Faculty/Staff.';

  static const SHUTTLE_MAX_TITLE = 'Maximum shuttle stops reached';
  static const SHUTTLE_MAX_DESC =
      'The maximum number of shuttle stops allowed is five. Please remove some stops to add more.';
}

class ParkingConstants {
  static const SPOT_MAX_TITLE = 'Maximum parking spots reached';
  static const SPOT_MAX_DESC =
      'The maximum number of parking spots allowed is three. Please remove some spots to add more.';
  static const LOT_MAX_TITLE = 'Maximum parking lots reached';
  static const LOT_MAX_DESC =
      'You have reached the maximum number of lots (10) that can be selected. Please deselect some lots before adding more.';
  static const Map<String, IconData> STRING_TO_ICON_DATA = {
    'icon - e03e': Icons.accessible,
    'icon - e486': Icons.group,
  };
}

class WifiConstants {
  // Initial State
  static const WIFI_ISSUE_FAILED_TITLE = 'Could not report issue';
  static const WIFI_ISSUE_FAILED_DESC = 'Please run speed test to report issue.';
  // Finished State
  static const WIFI_ISSUE_SUCCESS_TITLE = 'Issue Reported';
  static const WIFI_ISSUE_SUCCESS_DESC =
      'Thank you for helping improve UCSD wireless. Your test results have been sent to IT Services.';
}

class Plugins {
  static const FRONT_CAMERA = 'FRONT CAMERA';
}

class NavigatorConstants {
  static const HOME_TAB = 0;
  static const MAP_TAB = 1;
  static const AI_ASSISTANT_TAB = 2;
  static const CHAT_TAB = AI_ASSISTANT_TAB;
  static const NOTIFICATIONS_TAB = 3;
  static const PROFILE_TAB = 4;
}

class NotificationsConstants {
  static const STATUS_NO_MESSAGES = 'You have no notifications.\n' +
      'It looks like you\'ve unsubscribed from all topics.\n\n' +
      'You can re-subscribe to specific topics via the Notifications Filter.';
  static const STATUS_FETCH_PROBLEM = 'There was a problem fetching your messages.\n\n' + 'Please try again soon.';
  static const STATUS_FETCHING = 'Loading your notifications, please wait.';
  static const STATUS_NONE = '';
  static const STATUS_NO_MORE_MESSAGES = 'No more messages.';
}

class MessageTypeConstants {
  static const SUCCESS = 1;
  static const INFO = 2;
  static const WARNING = 3;
  static const ERROR = 4;
}

class DataPersistence {
  static const CARD_STATES = 'cardStates';
  static const CARD_ORDER = 'cardOrder';
  static const AUTHENTICATION_MODEL = 'AuthenticationModel';
  static const USER_PROFILE_MODEL = 'UserProfileModel';
}

/// Maps Card IDs to Card titles
class CardTitleConstants {
  static const TITLE_MAP = {
    'my_student_chart': 'MY STUDENT CHART',
    'my_ucsd_chart': 'MY UCSD CHART',
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
  static const RELOAD_CARD = 'reload card';
  static const HIDE_CARD = 'hide card';
}

class ConnectivityConstants {
  static const OFFLINE_ALERT = 'It appears you are currently offline. Check network status and try again.';
  static const OFFLINE_TITLE = 'No Internet';
}
