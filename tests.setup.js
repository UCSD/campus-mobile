// Needed to properly mock react-native-google-analytics-bridge
import { GoogleAnalyticsTracker } from 'react-native-google-analytics-bridge';

// Mock native modules here
jest.mock('react-native-simple-toast', () => 'Toast');
jest.mock('react-native-google-analytics-bridge');
