class CardTitleConstants {
  static const titleMap = {
    'QRScanner': 'QR Scanner',
    'MyStudentChart': 'MyStudentChart',
    'student_id': 'Student ID',
    'finals': 'Finals',
    'schedule': 'Classes',
    'dining': 'Dining',
    'availability': 'Availability',
    'events': 'Events',
    'news': 'News',
    'weather': 'Weather',
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

class ScannerConstants {
  static const scannerViewPrompt = 'Scan a test kit.';
  static const scannerCardPrompt = 'Scan Your COVID-19 Test Kit.';
  static const scannerSubmitPrompt = "Ready to submit";
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
