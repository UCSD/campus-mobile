// Needed to properly mock react-native-google-analytics-bridge
import { GoogleAnalyticsTracker } from 'react-native-google-analytics-bridge' // eslint-disable-line no-unused-vars

// Mock AppSettings here explicitly
// Needed because dev and prod values can differ, which may
// break certain snapshots under different testing environments

const AppSettingsMock = jest.genMockFromModule('./app/AppSettings')
AppSettingsMock.APP_NAME = 'Campus Mobile'
jest.setMock('./app/AppSettings', AppSettingsMock)

// Mock native modules here
jest.mock('react-native-google-analytics-bridge')
jest.mock('bugsnag-react-native')
jest.mock('react-native-simple-toast', () => ({ showWithGravity: () => jest.fn() }))
