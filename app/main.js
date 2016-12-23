'use strict';

import React, { Component } from 'react';
import { StatusBar,	View } from 'react-native';
import { Actions, Router, Scene } from 'react-native-router-flux';

import AppSettings from './AppSettings';
import css from './styles/css';
import general from './util/general';

// GPS
import GeoLocationContainer from './containers/geoLocationContainer';

// VIEWS
import Home from './views/Home';
import SurfReport from './views/weather/SurfReport';
import ShuttleStop from './views/shuttle/ShuttleStop';
import DiningList from './views/dining/DiningList';
import DiningDetail from './views/dining/DiningDetail';
import DiningNutrition from './views/dining/DiningNutrition';
import EventDetail from './views/events/EventDetail';
import WebWrapper from './views/WebWrapper';
import WelcomeWeekView from './views/welcomeWeek/WelcomeWeekView';
import QuicklinksListView from './views/quicklinks/QuicklinksListView';
import EventListView from './views/events/EventListView';
import NewsDetail from './views/news/NewsDetail';
import NewsListView from './views/news/NewsListView';
import DiningListView from './views/dining/DiningListView';
import FeedbackView from './views/FeedbackView';
import PreferencesView from './views/preferences/PreferencesView';
import NearbyMapView from './views/mapsearch/NearbyMapView';

// SCENES
const scenes = Actions.create(
	<Scene key='root'>
		<Scene key='Home' component={Home} title='now-mobile' initial={true} />
		<Scene key='SurfReport' component={SurfReport} title='Surf Report' />
		<Scene key='ShuttleStop' component={ShuttleStop} title='Shuttle' />
		<Scene key='DiningList' component={DiningList} title='Dining' />
		<Scene key='DiningDetail' component={DiningDetail} title='Dining' />
		<Scene key='DiningNutrition' component={DiningNutrition} title='Nutrition' />
		<Scene key='DiningListView' component={DiningListView} title='Dining' />
		<Scene key='EventDetail' component={EventDetail} title='Events' />
		<Scene key='WebWrapper' component={WebWrapper} title='WebWrapper' />
		<Scene key='WelcomeWeekView' component={WelcomeWeekView} title='Welcome Week' />
		<Scene key='QuicklinksListView' component={QuicklinksListView} title='Links' />
		<Scene key='EventListView' component={EventListView} title='Events' />
		<Scene key='NewsDetail' component={NewsDetail} title='News' />
		<Scene key='NewsListView' component={NewsListView} title='News' />
		<Scene key='FeedbackView' component={FeedbackView} title='Feedback' />
		<Scene key='PreferencesView' component={PreferencesView} title='Settings' />
		<Scene key='NearbyMapView' component={NearbyMapView} title='Map' />
	</Scene>
);

export default class Main extends Component {
	render() {
		if (general.platformIOS()) {
			StatusBar.setBarStyle('light-content');
		}
		return (
			<View style={css.flex}>
				<GeoLocationContainer />
				<Router
					scenes={scenes}
					navigationBarStyle={css.navigator}
					titleStyle={css.navigatorTitle}
					barButtonIconStyle={css.barButtonIconStyle}
				/>
			</View>			
		);
	}
}
