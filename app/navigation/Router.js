import React from 'react';
import { View } from 'react-native';
import { StackNavigator, TabNavigator } from 'react-navigation';
import { MenuProvider } from 'react-native-popup-menu';

import general from '../util/general';

// VIEWS
import Home from '../views/Home';
import SurfReport from '../views/weather/SurfReport';
import ShuttleStop from '../views/shuttle/ShuttleStop';
import DiningDetail from '../views/dining/DiningDetail';
import DiningNutrition from '../views/dining/DiningNutrition';
import EventDetail from '../views/events/EventDetail';
import NewsDetail from '../views/news/NewsDetail';
import FeedbackView from '../views/feedback/FeedbackView';
import PreferencesView from '../views/preferences/PreferencesView';
import NearbyMapView from '../views/mapsearch/NearbyMapView';
import DataListViewAll from '../views/common/DataListViewAll';
import SpecialEventsView from '../views/specialEvents/SpecialEventsView';
import SpecialEventsDetailView from '../views/specialEvents/SpecialEventsDetailView';
import ShuttleRoutesListView from '../views/shuttle/ShuttleRoutesListView';
import ShuttleStopsListView from '../views/shuttle/ShuttleStopsListView';
import ShuttleSavedListView from '../views/shuttle/ShuttleSavedListView';

// TABS
import TabIcons from './TabIcons';

// ROUTER UTIL
import withNavigationPreventDuplicate from './withNavigationPreventDuplicate';

import {
	COLOR_SECONDARY,
	COLOR_WHITE,
	COLOR_MGREY
} from '../styles/ColorConstants';
import css from '../styles/css';

const TabNav = TabNavigator(
	{
		Home: { screen: Home },
		Map: { screen: NearbyMapView },
		Feedback: { screen: FeedbackView },
		Preferences: { screen: PreferencesView }
	},
	{
		tabBarOptions: {
			showLabel: false,
			showIcon: true,
			pressColor: COLOR_MGREY,
			indicatorStyle: { backgroundColor: COLOR_SECONDARY },
			style: general.platformIOS() ? css.tabBarIOS : css.tabBarAndroid,
			iconStyle: { width: 26, height: 26 }
		},
		navigationOptions: ({ navigation }) => ({
			tabBarIcon: ({ focused }) => {
				const { routeName } = navigation.state;
				return <TabIcons title={routeName} focused={focused} />;
			}
		})
	}
);

const DummyView = () => (<View />); /* Workaround for misaligned title */

const MainStack = StackNavigator(
	{
		MainTabs: {
			screen: TabNav
		},
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
		SpecialEventsView: {
			screen: SpecialEventsView,
			navigationOptions: ({ navigation }) => {
				const { params } = navigation.state;
				const { title } = params;
				return {
					title,
					headerRight: (<DummyView />)
				};
			}
		},
		SpecialEventsDetailView: {
			screen: SpecialEventsDetailView,
			navigationOptions: ({ navigation }) => {
				const { params } = navigation.state;
				const { title } = params;
				return {
					title,
					headerRight: (<DummyView />)
				};
			}
		},
		DataListViewAll: {
			screen: DataListViewAll,
			navigationOptions: ({ navigation }) => {
				const { params } = navigation.state;
				const { title } = params;
				return {
					title,
					headerRight: (<DummyView />)
				};
			}
		}
	},
	{
		initialRouteName: 'MainTabs',
		navigationOptions: {
			headerStyle: css.nav,
			headerTitleStyle: css.navTitle,
			headerTintColor: COLOR_WHITE
		}
	}
);

MainStack.router.getStateForAction =
withNavigationPreventDuplicate(MainStack.router.getStateForAction);

const Router = () => (
	<MenuProvider style={{ flex:1 }}>
		<MainStack />
	</MenuProvider>
);

export default Router;
