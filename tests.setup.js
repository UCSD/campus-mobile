// Needed to properly mock react-native-google-analytics-bridge
import { GoogleAnalyticsTracker } from 'react-native-google-analytics-bridge'

// Mock AppSettings here explicitly
// Needed because dev and prod values can differ, which may
// break certain snapshots under different testing environments

const AppSettingsMock = jest.genMockFromModule('./app/AppSettings')
AppSettingsMock.APP_NAME = 'Campus Mobile'
jest.setMock('./app/AppSettings', AppSettingsMock)

// Mock native modules here

// Mock Google analytics
// used by various components
jest.mock('react-native-google-analytics-bridge')

// Mock bugsnag
jest.mock('bugsnag-react-native')

// Mock react-native-simple-toast
// used by Feedback and NearbyMapView
jest.mock('react-native-simple-toast', () => {
	return {
		showWithGravity: () => jest.fn()
	}
})
