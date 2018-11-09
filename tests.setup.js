// Mock AppSettings here explicitly
// Needed because dev and prod values can differ, which may
// break certain snapshots under different testing environments

const AppSettingsMock = jest.genMockFromModule('./app/AppSettings')
AppSettingsMock.APP_NAME = 'Campus Mobile'
jest.setMock('./app/AppSettings', AppSettingsMock)

// Mock native modules here
jest.mock('bugsnag-react-native')
jest.mock('react-native-simple-toast', () => ({ showWithGravity: () => jest.fn() }))
