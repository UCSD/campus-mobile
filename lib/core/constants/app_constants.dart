class RoutePaths {
  static const String Home = '/';
  static const String BottomNavigationBar = 'bottom_navigation_bar';
  static const String Onboarding = 'onboarding';
  static const String OnboardingLogin = 'onboarding/login';
  static const String Map = 'map/map';
  static const String MapSearch = 'map/map_search';
  static const String MapLocationList = 'map/map_location_list';
  static const String Notifications = 'notifications';
  static const String Profile = 'profile';
  static const String CardsView = 'profile/cards_view';
  static const String NotificationsSettingsView =
      'notifications/notifications_settings';

  static const String NewsViewAll = 'news/newslist';
  static const String BaseLineView = 'baseline/baselineview';
  static const String EventsViewAll = 'events/eventslist';
  static const String NewsDetailView = 'news/news_detail_view';
  static const String EventDetailView = 'events/event_detail_view';
  static const String LinksViewAll = 'links/links_list';
  static const String ClassScheduleViewAll = 'class/classList';
  static const String ManageAvailabilityView =
      'availability/manage_locations_view';
  static const String ManageParkingView = 'parking/manage_parking_view';
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
    'parking/manage_parking_view': 'Parking',
    'dining/dining_list_view': 'Dining',
    'dining/dining_detail_view': 'Dining',
    'dining/dining_nutrition_view': 'Dining',
    'special_events/special_events_list_view': 'Special Events',
    'special_events/special_events_filter_view': 'Special Events',
    'special_events/special_events_detail_view': 'Special Events',
    'scanner/scanner_view': 'Scanner',
  };
}

class ButtonText {
  static const SubmitButtonActive = 'Submit';
  static const SubmitButtonInactive = 'Sending';
  static const SubmitButtonTryAgain = 'Try again';
  static const SubmitButtonReceived = 'Received';
  static const ScanNowFull = 'Scan Your COVID-19 Test Kit.';
  static const ScanNow = 'Scan Now';
  static const SignInFull = 'Sign In to Scan Your COVID-19 Test Kit.';
  static const SignIn = 'Sign In';
}

class ErrorConstants {
  static const authorizedPostErrors = 'Failed to upload data: ';
  static const invalidBearerToken = 'Invalid bearer token';
}

class Plugins {
  static const FrontCamera = 'FRONT CAMERA';
}

class NavigationConstants {
  static const HomeTab = 0;
  static const MapTab = 1;
  static const NotificationsTab = 2;
  static const ProfileTab = 3;
}

/// Maps Card IDs to Card titles
class CardTitleConstants {
  static const titleMap = {
    'QRScanner': 'QR Scanner',
    'MyStudentChart': 'MyStudentChart',
    'staff_info': 'COVID-19 Info',
    'campus_info': "Campus Information",
    'student_info': 'COVID-19 Info',
    'student_id': 'Student ID',
    'staff_id': 'Staff ID',
    'finals': 'Finals',
    'schedule': 'Classes',
    'dining': 'Dining',
    'availability': 'Availability',
    'events': 'Events',
    'news': 'News',
    'weather': 'Weather',
  };
}
