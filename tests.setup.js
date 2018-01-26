// Needed to properly mock react-native-google-analytics-bridge
import { GoogleAnalyticsTracker } from 'react-native-google-analytics-bridge';

// Mock AppSettings here explicitly
// Needed because dev and prod values can differ, which may
// break certain snapshots under different testing environments

const AppSettingsMock = jest.genMockFromModule('./app/AppSettings');
AppSettingsMock.APP_NAME = 'Campus Mobile';
jest.setMock('./app/AppSettings', AppSettingsMock);

// Mock native modules here

// Mock Google analytics
// used by various components
jest.mock('react-native-google-analytics-bridge');

// Mock react-native-simple-toast
// used by Feedback and NearbyMapView
jest.mock('react-native-simple-toast', () => 'Toast');

// Mock react-native-experimental navigation Linking
// used by Home
jest.mock('Linking', () => ({
	addEventListener: jest.fn(),
	removeEventListener: jest.fn(),
	openURL: jest.fn(),
	canOpenURL: jest.fn(),
	getInitialURL: jest.fn(),
}));
