import React from 'react'
import { View } from 'react-native'
import {
	createStackNavigator,
	createBottomTabNavigator,
	createAppContainer
} from 'react-navigation'
import { MenuProvider } from 'react-native-popup-menu'
import { connect } from 'react-redux'


// VIEWS
import Home from '../views/home/Home'
import OnboardingIntro from '../views/login/OnboardingIntro'
import OnboardingLogin from '../views/login/OnboardingLogin'
import SurfReport from '../views/weather/SurfReport'
import ShuttleStop from '../views/shuttle/ShuttleStop'
import DiningDetail from '../views/dining/DiningDetail'
import DiningNutrition from '../views/dining/DiningNutrition'
import EventDetail from '../views/events/EventDetail'
import NewsDetail from '../views/news/NewsDetail'
import Feedback from '../views/preferences/feedback/Feedback'
import Messaging from '../views/messaging/Messaging'
import Preferences from '../views/preferences/Preferences'
import Map from '../views/map/Map'
import DataListViewAll from '../views/common/DataListViewAll'
import SpecialEventsView from '../views/specialEvents/SpecialEventsView'
import SpecialEventsDetailView from '../views/specialEvents/SpecialEventsDetailView'
import SpecialEventsFilterListView from '../views/specialEvents/SpecialEventsFilterListView'
import ShuttleRoutesListView from '../views/shuttle/ShuttleRoutesListView'
import ShuttleStopsListView from '../views/shuttle/ShuttleStopsListView'
import ShuttleSavedListView from '../views/shuttle/ShuttleSavedListView'
import FullSchedule from '../views/schedule/FullScheduleListView'
import ParkingSpotType from '../views/parking/ParkingSpotType'
import ManageParkingLots from '../views/parking/ManageParkingLots'
import Notifications from '../views/preferences/notifications/Notifications'
import CardPreferences from '../views/preferences/card/CardPreferences'


// TABS
import TabIcons from './TabIcons'

// ROUTER UTIL
import withNavigationPreventDuplicate from './withNavigationPreventDuplicate'

// MISC
import COLOR from '../styles/ColorConstants'
import css from '../styles/css'
import general from '../util/general'
import NavigationService from './NavigationService'

const TabNav = createBottomTabNavigator(
	{
		Home: { screen: Home },
		Map: { screen: Map },
		Messaging: { screen: Messaging },
		Preferences: { screen: Preferences }
	},
	{
		tabBarOptions: {
			showLabel: false,
			showIcon: true,

			pressColor: COLOR.MGREY,
			indicatorStyle: { backgroundColor: COLOR.SECONDARY },
			style: general.platformIOS() ? css.tabBarIOS : css.tabBarAndroid,
			iconStyle: {
				width: 26,
				height: 26
			}
		},
		defaultNavigationOptions: ({ navigation }) => ({
			tabBarIcon: ({ focused }) => {
				const { routeName } = navigation.state
				return <TabIcons title={routeName} focused={focused} />
			},
			swipeEnabled: false
		})
	}
)

const DummyView = () => (<View />) /* Workaround for misaligned title */

let MainStack = createStackNavigator(
	{
		MainTabs: { screen: TabNav },
		SurfReport: {
			screen: SurfReport,
			defaultNavigationOptions: {
				title: 'Surf Report',
				headerRight: (<DummyView />)
			}
		},
		NewsDetail: {
			screen: NewsDetail,
			defaultNavigationOptions: {
				title: 'News',
				headerRight: (<DummyView />)
			}
		},
		EventDetail: {
			screen: EventDetail,
			defaultNavigationOptions: {
				title: 'Events',
				headerRight: (<DummyView />)
			}
		},
		DiningDetail: {
			screen: DiningDetail,
			defaultNavigationOptions: {
				title: 'Dining',
				headerRight: (<DummyView />)
			}
		},
		DiningNutrition: {
			screen: DiningNutrition,
			defaultNavigationOptions: {
				title: 'Nutrition',
				headerRight: (<DummyView />)
			}
		},
		ShuttleStop: {
			screen: ShuttleStop,
			defaultNavigationOptions: {
				title: 'Shuttle',
				headerRight: (<DummyView />)
			}
		},
		ShuttleStopsListView: {
			screen: ShuttleStopsListView,
			defaultNavigationOptions: {
				title: 'Choose Stop',
				headerRight: (<DummyView />)
			}
		},
		ShuttleSavedListView: {
			screen: ShuttleSavedListView,
			defaultNavigationOptions: {
				title: 'Manage Stops',
				headerRight: (<DummyView />)
			}
		},
		ShuttleRoutesListView: {
			screen: ShuttleRoutesListView,
			defaultNavigationOptions: {
				title: 'Choose Route',
				headerRight: (<DummyView />)
			}
		},
		ParkingSpotType: {
			screen: ParkingSpotType,
			defaultNavigationOptions: {
				title: 'Spot Types',
				headerRight: (<DummyView />)
			}
		},
		ManageParkingLots: {
			screen: ManageParkingLots,
			defaultNavigationOptions: {
				title: 'Manage Lots',
				headerRight: (<DummyView />)
			}
		},
		SpecialEventsView: { screen: SpecialEventsView },
		SpecialEventsFilters: {
			screen: SpecialEventsFilterListView,
			defaultNavigationOptions: ({ navigation }) => {
				const { params } = navigation.state
				const { title } = params
				return {
					title,
					headerRight: (<DummyView />)
				}
			}
		},
		SpecialEventsDetailView: {
			screen: SpecialEventsDetailView,
			defaultNavigationOptions: ({ navigation }) => {
				const { params } = navigation.state
				const { title } = params
				return {
					title,
					headerRight: (<DummyView />)
				}
			}
		},
		FullSchedule: {
			screen: FullSchedule,
			defaultNavigationOptions: {
				title: 'Classes',
				headerRight: (<DummyView />)
			}
		},
		LoginScreen: {
			screen: OnboardingLogin,
			defaultNavigationOptions: { header: null }
		},
		Feedback: {
			screen: Feedback,
			defaultNavigationOptions: {
				title: 'Feedback',
				headerRight: (<DummyView />)
			}
		},
		Notifications: {
			screen: Notifications,
			defaultNavigationOptions: {
				title: 'Notifications',
				headerRight: (<DummyView />)
			}
		},
		CardPreferences: {
			screen: CardPreferences,
			defaultNavigationOptions: {
				title: 'Cards',
				headerRight: (<DummyView />)
			}
		},
		DataListViewAll: {
			screen: DataListViewAll,
			defaultNavigationOptions: ({ navigation }) => {
				const { params } = navigation.state
				const { title } = params
				return {
					title,
					headerRight: (<DummyView />)
				}
			}
		}
	},
	{
		initialRouteName: 'MainTabs',
		defaultNavigationOptions: {
			headerStyle: css.nav,
			headerTitleStyle: css.navTitle,
			headerTintColor: COLOR.WHITE
		},
		cardStyle: { backgroundColor: COLOR.LGREY2 }
	}
)

let OnboardingStack = createStackNavigator(
	{
		OnboardingIntro: {
			screen: OnboardingIntro,
			defaultNavigationOptions: { header: null }
		},
		OnboardingLogin: {
			screen: OnboardingLogin,
			defaultNavigationOptions: { header: null }
		},
	},
	{
		initialRouteName: 'OnboardingIntro',
		headerMode: 'none',
		cardStyle: { backgroundColor: COLOR.LGREY2 }
	},
)

MainStack.router.getStateForAction = withNavigationPreventDuplicate(MainStack.router.getStateForAction)
OnboardingStack.router.getStateForAction = withNavigationPreventDuplicate(OnboardingStack.router.getStateForAction)

MainStack = createAppContainer(MainStack)
OnboardingStack = createAppContainer(OnboardingStack)

const Router = ({ onBoardingViewed }) => (
	<MenuProvider>
		{
			(onBoardingViewed) ? (
				<MainStack ref={navigatorRef => NavigationService.setTopLevelNavigator(navigatorRef)} />
			) : (
				<OnboardingStack ref={navigatorRef => NavigationService.setTopLevelNavigator(navigatorRef)} />
			)
		}
	</MenuProvider>
)

const mapStateToProps = (state, props) => (
	{ onBoardingViewed: state.routes.onBoardingViewed }
)

export default connect(mapStateToProps)(Router)
