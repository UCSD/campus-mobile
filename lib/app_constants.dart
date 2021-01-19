class RoutePaths {
  static const String Home = '/';
  static const String BottomNavigationBar = 'bottom_navigation_bar';
  static const String Onboarding = 'onboarding';
  static const String OnboardingInitial = 'onboarding/initial';
  static const String OnboardingLogin = 'onboarding/login';
  static const String OnboardingAffiliations = 'onboarding/affiliations';
  static const String Map = 'map/map';
  static const String MapSearch = 'map/map_search';
  static const String MapLocationList = 'map/map_location_list';
  static const String Notifications = 'notifications';
  static const String Profile = 'profile';
  static const String CardsView = 'profile/cards_view';
  static const String BeaconView = 'profile/beacon_view';
  static const String AutomaticBluetoothLoggerView =
      'profile/automatic_bluetooth_logger_view';
  static const String BluetoothPermissionsView =
      'profile/bluetooth_permissions_view';
  static const String NetworkAnalysisView =
      'profile/network_analysis_view';
  static const String NotificationsSettingsView =
      'notifications/notifications_settings';

  static const String NewsViewAll = 'news/newslist';
  static const String EventsViewAll = 'events/eventslist';
  static const String NewsDetailView = 'news/news_detail_view';
  static const String EventDetailView = 'events/event_detail_view';
  static const String LinksViewAll = 'links/links_list';
  static const String ClassScheduleViewAll = 'class/classList';
  static const String ManageAvailabilityView =
      'availability/manage_locations_view';
  static const String ManageParkingView = 'parking/manage_parking_view';
  static const String ManageShuttleView = 'shuttle/manage_shuttle_view';
  static const String AddShuttleStopsView = 'shuttle/add_shuttle_stops_view';
  static const String DiningViewAll = 'dining/dining_list_view';
  static const String DiningDetailView = 'dining/dining_detail_view';
  static const String DiningNutritionView = 'dining/dining_nutrition_view';
  static const String SurfView = 'surfing/surf_view';
  static const String SpecialEventsListView =
      'special_events/special_events_list_view';
  static const String SpecialEventsFilterView =
      'special_events/special_events_filter_view';
  static const String SpecialEventsDetailView =
      'special_events/special_events_detail_view';
  static const String ScannerView = 'scanner/scanner_view';
  static const String ScanditScanner = 'scanner/scandit_scanner';
  static const String Parking = "parking/parking_view";
  static const String SpotTypesView = "parking/spot_types_view";
  static const String ParkingLotsView = "parking/parking_lots_view";
}

class RouteTitles {
  static const titleMap = {
    'Maps': 'Maps',
    'MapSearch': 'Maps',
    'MapLocationList': 'Maps',
    'Notifications': 'Notifications',
    'Profile': 'Profile',
    'profile/cards_view': 'Cards',
    'notifications/notifications_settings': "Notification Settings",
    'news/newslist': 'News',
    'news/news_detail_view': 'News',
    'events/eventslist': 'Events',
    'events/event_detail_view': 'Events',
    'class/classList': 'Class Schedule',
    'availability/manage_locations_view': 'Manage Locations',
    'shuttle/manage_shuttle_view': 'Manage Shuttle Stops',
    'shuttle/add_shuttle_stops_view': 'Add Shuttle Stops',
    'parking/manage_parking_view': 'Parking',
    'dining/dining_list_view': 'Dining',
    'dining/dining_detail_view': 'Dining',
    'dining/dining_nutrition_view': 'Dining',
    'special_events/special_events_list_view': 'Special Events',
    'special_events/special_events_filter_view': 'Special Events',
    'special_events/special_events_detail_view': 'Special Events',
  };
}

class ParkingDefaults {
  static const defaultLots = ["P406", "P784", "P782", "P386", "P704", "P705"];
  static const defaultSpots = ["S", "B", "A"];
}

class ButtonText {
  static const ScanNowFull = 'Scan Your COVID-19 Test Kit.';
  static const ScanNow = 'Scan Now';
  static const SignInFull = 'Sign In to Scan Your COVID-19 Test Kit.';
  static const SignIn = 'Sign In';
}

class ErrorConstants {
  static const authorizedPostErrors = 'Failed to upload data: ';
  static const authorizedPutErrors = 'Failed to update data: ';
  static const invalidBearerToken = 'Invalid bearer token';
  static const duplicateRecord =
      'DioError [DioErrorType.RESPONSE]: Http status error [409]';
  static const invalidMedia =
      'DioError [DioErrorType.RESPONSE]: Http status error [415]';
}

class ScannerConstants {
  static const duplicateRecord =
      'Submission failed due to barcode already scanned. Please scan another barcode.\nCode #1035';
  static const invalidMedia =
      'Barcode is not valid. Please scan another barcode.\nCode #1036';
  static const barcodeError =
      'An error occurred. Please try again.\nCode #1037';
  static const invalidToken =
      'An error occurred. Please try again.\nCode #1038';
  static const loggedOut = 'An error occurred. Please try again.\nCode #1039';
  static const unknownError =
      'An error occurred. Please try again.\nCode #1040';
  static const scannerReauthFailure =
      'Your session has expired. Please login to submit a scan.';
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
      'You may be opted out of all topics.\n\n' +
      'Notifications to specific topics can be turned on in User Profile.';
  static const statusFetchProblem =
      'There was a problem fetching your messages.\n\n' +
          'Please try again soon.';
  static const statusFetching = 'Loading your notifications, please wait.';
  static const statusNone = '';
  static const statusNoMoreMessages = 'No more messages.';
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
    'QRScanner': 'Scanner', // Web Scanner
    'NativeScanner': 'Scanner',
    'MyStudentChart': 'MyStudentChart',
    'MyUCSDChart': 'MyUCSDChart',
    'staff_info': 'COVID-19 Info',
    'campus_info': "Campus Information",
    'student_info': 'COVID-19 Info',
    'student_survey': 'Student Survey',
    'student_id': 'Student ID',
    'speed_test' : "Speed Test",
    'staff_id': 'Staff ID',
    'finals': 'Finals',
    'schedule': 'Classes',
    'shuttle': "Shuttle",
    'dining': 'Dining',
    'availability': 'Availability',
    'events': 'Events',
    'news': 'News',
    'parking': 'Parking',
    'special_events': 'Special Events',
    'weather': 'Weather',
  };
}
