import React from 'react'
import { View, Image } from 'react-native'
import {
	createStackNavigator,
	createBottomTabNavigator,
	createMaterialTopTabNavigator,
	createAppContainer
} from 'react-navigation'
import { MenuProvider } from 'react-native-popup-menu'
import { connect } from 'react-redux'
import { platformAndroid } from '../util/general'
import css from '../styles/css'
import COLOR from '../styles/ColorConstants'
import TabIcons from './TabIcons'
import NavigationService from './NavigationService'

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

const campusLogoImage = require('../assets/images/UCSanDiegoLogo-nav.png')

let TabNav

if (platformAndroid()) {
	TabNav = createMaterialTopTabNavigator(
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
				indicatorStyle: { backgroundColor: COLOR.TRANSPARENT },
				style: css.tabBar,
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
} else {
	TabNav = createBottomTabNavigator(
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
				indicatorStyle: { backgroundColor: 'green' },
				style: css.tabBar,
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
}

TabNav.navigationOptions = ({ navigation }) => {
	const { routeName } = navigation.state.routes[navigation.state.index]
	const headerTitle = ( routeName === 'Home') ? <Image source={campusLogoImage} style={css.navCampusLogoTitle} /> : routeName
	return { headerTitle }
}

const DummyView = () => (<View />) /* Workaround for misaligned title */

let MainStack = createStackNavigator(
	{
		MainTabs: { screen: TabNav },
		SurfReport: {
			screen: SurfReport,
			navigationOptions: {
				title: 'Surf Report',
				headerRight: (<DummyView />)
			}
		},
		NewsDetail: {
			screen: NewsDetail,
			navigationOptions: {
				title: 'News',
				headerRight: (<DummyView />)
			}
		},
		EventDetail: {
			screen: EventDetail,
			navigationOptions: {
				title: 'Events',
				headerRight: (<DummyView />)
			}
		},
		DiningDetail: {
			screen: DiningDetail,
			navigationOptions: {
				title: 'Dining',
				headerRight: (<DummyView />)
			}
		},
		DiningNutrition: {
			screen: DiningNutrition,
			navigationOptions: {
				title: 'Nutrition',
				headerRight: (<DummyView />)
			}
		},
		ShuttleStop: {
			screen: ShuttleStop,
			navigationOptions: {
				title: 'Shuttle',
				headerRight: (<DummyView />)
			}
		},
		ShuttleStopsListView: {
			screen: ShuttleStopsListView,
			navigationOptions: {
				title: 'Choose Stop',
				headerRight: (<DummyView />)
			}
		},
		ShuttleSavedListView: {
			screen: ShuttleSavedListView,
			navigationOptions: {
				title: 'Manage Stops',
				headerRight: (<DummyView />)
			}
		},
		ShuttleRoutesListView: {
			screen: ShuttleRoutesListView,
			navigationOptions: {
				title: 'Choose Route',
				headerRight: (<DummyView />)
			}
		},
		ParkingSpotType: {
			screen: ParkingSpotType,
			navigationOptions: {
				title: 'Spot Types',
				headerRight: (<DummyView />)
			}
		},
		ManageParkingLots: {
			screen: ManageParkingLots,
			navigationOptions: {
				title: 'Manage Lots',
				headerRight: (<DummyView />)
			}
		},
		SpecialEventsView: { screen: SpecialEventsView },
		SpecialEventsFilters: {
			screen: SpecialEventsFilterListView,
			navigationOptions: ({ navigation }) => {
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
			navigationOptions: ({ navigation }) => {
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
			navigationOptions: {
				title: 'Classes',
				headerRight: (<DummyView />)
			}
		},
		LoginScreen: {
			screen: OnboardingLogin,
			navigationOptions: { header: null }
		},
		Feedback: {
			screen: Feedback,
			navigationOptions: {
				title: 'Feedback'
			}
		},
		Notifications: {
			screen: Notifications,
			navigationOptions: {
				title: 'Notifications',
				headerRight: (<DummyView />)
			}
		},
		CardPreferences: {
			screen: CardPreferences,
			navigationOptions: {
				title: 'Cards',
				headerRight: (<DummyView />)
			}
		},
		DataListViewAll: {
			screen: DataListViewAll,
			navigationOptions: ({ navigation }) => {
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
			headerTintColor: COLOR.WHITE,

		},
		cardStyle: { backgroundColor: COLOR.LGREY2 }
	}
)

let OnboardingStack = createStackNavigator(
	{
		OnboardingIntro: {
			screen: OnboardingIntro,
			navigationOptions: { header: null }
		},
		OnboardingLogin: {
			screen: OnboardingLogin,
			navigationOptions: { header: null }
		},
	},
	{
		initialRouteName: 'OnboardingIntro',
		headerMode: 'none',
		cardStyle: { backgroundColor: COLOR.LGREY2 }
	},
)

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
