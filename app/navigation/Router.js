import React from 'react'
import { Image } from 'react-native'
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

import CourseView from '../views/course/CourseView'

const campusLogoImage = require('../assets/images/UCSanDiegoLogo-nav.png')

const TabNavScreens = {
	Home: { screen: Home },
	Map: { screen: Map },
	Messaging: { screen: Messaging },
	Preferences: { screen: Preferences }
}

const TabNavSetup = {
	tabBarOptions: {
		showLabel: false,
		showIcon: true,
		pressColor: COLOR.MGREY,
		indicatorStyle: { backgroundColor: platformAndroid() ? COLOR.PRIMARY : COLOR.TRANSPARENT },
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

let TabNav
if (platformAndroid()) {
	TabNav = createMaterialTopTabNavigator(TabNavScreens, TabNavSetup)
} else {
	TabNav = createBottomTabNavigator(TabNavScreens, TabNavSetup)
}

TabNav.navigationOptions = ({ navigation }) => {
	const { routeName } = navigation.state.routes[navigation.state.index]
	let headerTitle = ( routeName === 'Home') ? <Image source={campusLogoImage} style={css.navCampusLogoTitle} /> : routeName
	switch (routeName) {
		case 'Messaging':
			headerTitle = 'Notifications'
			break
		case 'Preferences':
			headerTitle = 'User Profile'
	}
	return { headerTitle }
}

let MainStack = createStackNavigator(
	{
		MainTabs: { screen: TabNav },
		SurfReport: {
			screen: SurfReport,
			navigationOptions: {
				title: 'Surf Report'
			}
		},
		NewsDetail: {
			screen: NewsDetail,
			navigationOptions: {
				title: 'News',
			}
		},
		EventDetail: {
			screen: EventDetail,
			navigationOptions: {
				title: 'Events',
			}
		},
		DiningDetail: {
			screen: DiningDetail,
			navigationOptions: {
				title: 'Dining',
			}
		},
		DiningNutrition: {
			screen: DiningNutrition,
			navigationOptions: {
				title: 'Nutrition',
			}
		},
		ShuttleStop: {
			screen: ShuttleStop,
			navigationOptions: {
				title: 'Shuttle',
			}
		},
		ShuttleStopsListView: {
			screen: ShuttleStopsListView,
			navigationOptions: {
				title: 'Choose Stop',
			}
		},
		ShuttleSavedListView: {
			screen: ShuttleSavedListView,
			navigationOptions: {
				title: 'Manage Stops',
			}
		},
		ShuttleRoutesListView: {
			screen: ShuttleRoutesListView,
			navigationOptions: {
				title: 'Choose Route',
			}
		},
		ParkingSpotType: {
			screen: ParkingSpotType,
			navigationOptions: {
				title: 'Spot Types',
			}
		},
		ManageParkingLots: {
			screen: ManageParkingLots,
			navigationOptions: {
				title: 'Manage Lots',
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
				}
			}
		},
		FullSchedule: {
			screen: FullSchedule,
			navigationOptions: {
				title: 'Classes',
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
			}
		},
		CardPreferences: {
			screen: CardPreferences,
			navigationOptions: {
				title: 'Cards',
			}
		},
		DataListViewAll: {
			screen: DataListViewAll,
			navigationOptions: ({ navigation }) => {
				const { params } = navigation.state
				const { title } = params
				return { title }
			}
		},
		CourseView: {
			screen: CourseView,
			navigationOptions: {
				title: 'Course Detail'
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
		headerLayoutPreset: 'center',
		cardStyle: { backgroundColor: COLOR.BG_GRAY }
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
		cardStyle: { backgroundColor: COLOR.BG_GRAY }
	},
)

MainStack = createAppContainer(MainStack)
OnboardingStack = createAppContainer(OnboardingStack)

const Router = ({ onBoardingViewed }) => {
	if (onBoardingViewed) {
		return (
			<MenuProvider>
				<MainStack ref={navigatorRef => NavigationService.setTopLevelNavigator(navigatorRef)} />
			</MenuProvider>
		)
	} else {
		return (
			<OnboardingStack ref={navigatorRef => NavigationService.setTopLevelNavigator(navigatorRef)} />
		)
	}
}

const mapStateToProps = (state, props) => (
	{ onBoardingViewed: state.routes.onBoardingViewed }
)

export default connect(mapStateToProps)(Router)
