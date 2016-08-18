'use strict';

import React, { Component } from 'react';
import {
	AppRegistry,
	NavigatorIOS,
	BackAndroid,
	StatusBar
} from 'react-native';

// SETUP / UTIL / NAV
var AppSettings = 			require('./app/AppSettings'),
	general = 				require('./app/util/general'),
	logger = 				require('./app/util/logger'),

// VIEWS
	Home = 					require('./app/views/Home'),
	ShuttleStop = 			require('./app/views/ShuttleStop'),
	SurfReport = 			require('./app/views/weather/SurfReport'),
	TopStoriesDetail = 		require('./app/views/topStories/TopStoriesDetail'),
	EventDetail = 			require('./app/views/events/EventDetail'),
	WebWrapper = 			require('./app/views/WebWrapper'),
	DestinationDetail = 	require('./app/views/DestinationDetail');

import WelcomeWeekView from './app/views/welcomeWeek/WelcomeWeekView';

// NAV
import NavigationBarWithRouteMapper from './app/views/NavigationBarWithRouteMapper';


var nowucsandiego = React.createClass({

	getInitialState() {
		return {
			pauseRefresh: false,
		};
	},

	componentDidMount() {
		if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
			// Listen to route focus changes
			// Should be a better way to do this...
			this.refs.navRef.refs.navRef.navigationContext.addListener('willfocus', (event) => {
				const route = event.data.route;
				console.log("Willfocus: " + JSON.stringify(route.id));

				// Make sure renders/card refreshes are only happening when in home route
				if (route.id === "Home") {
					this.setState({ pauseRefresh: false });
				} else {
					this.setState({ pauseRefresh: true });
				}
			});

			// Listen to back button on Android
			BackAndroid.addEventListener('hardwareBackPress', () => {
				//console.log("Backbutton: " + this.refs.navRef.navigationContext.route);
				if(this.state.pauseRefresh) {
					this.refs.navRef.refs.navRef.pop();
					return true;
				} else {
					BackAndroid.exitApp();
					return false;
				}
			});
		}
	},

	render: function() {
		if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
			return (
				<NavigationBarWithRouteMapper
					ref="navRef"
					route={{id: 'Home', name: 'Home', title: 'now@ucsandiego'}}
					renderScene={this.renderScene}
				/>
			);
		} else {
			StatusBar.setBarStyle('light-content');
			return (
				<NavigatorIOS
					initialRoute={{ 
						component: Home, 
						title: AppSettings.APP_NAME, 
						passProps: {
							isSimulator: this.props.isSimulator,
							pauseRefresh: this.state.pauseRefresh
						},
						backButtonTitle: "Back"
					}}
					style={{flex: 1}}
					tintColor='#FFFFFF'
					barTintColor='#006C92'
					titleTextColor='#FFFFFF'
					navigationBarHidden={false}
					translucent={true} 
					ref="navRef"
				/>
			);
		}
	},

	renderScene: function(route, navigator, index, navState) {
		switch (route.id) {
			case 'Home': 				return (<Home route={route} navigator={navigator} />);
			case 'ShuttleStop': 		return (<ShuttleStop route={route} navigator={navigator} />);
			case 'SurfReport': 			return (<SurfReport route={route} navigator={navigator} />);
			case 'TopStoriesDetail': 	return (<TopStoriesDetail route={route} navigator={navigator} />);
			case 'EventDetail': 		return (<EventDetail route={route} navigator={navigator} />);
			case 'WebWrapper': 			return (<WebWrapper route={route} navigator={navigator} />);
			case 'WelcomeWeekView': 	return (<WelcomeWeekView route={route} navigator={navigator} />);
			case 'DestinationDetail': 	return (<DestinationDetail route={route} navigator={navigator} />);
			default: 					return (<Home route={route} navigator={navigator} />);
		}
	},

});

AppRegistry.registerComponent('nowucsandiego', () => nowucsandiego);