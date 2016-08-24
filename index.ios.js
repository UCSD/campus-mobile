'use strict';

import React, { Component } from 'react';
import {
	AppRegistry,
	NavigatorIOS,
	BackAndroid,
	StatusBar,
	AppState
} from 'react-native';
import TimerMixin from 'react-timer-mixin';

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

/**
 * Timeout that allows for pause and resume
**/
function Timer(callback, delay) {
	var timerId, start, remaining = delay;

	this.pause = function() {
		clearTimeout(timerId);
		remaining -= new Date() - start;
	};

	this.resume = function() {
		start = new Date();
		clearTimeout(timerId);
		timerId = setTimeout(callback, remaining);
	};

	this.getID = function() {
		return timerId;
	};

	this.resume();
}
var timers = {};

var nowucsandiego = React.createClass({

	mixins: [TimerMixin],

	getInitialState() {
		return {};
	},

	componentWillMount() {
		AppState.addEventListener('change', this.handleAppStateChange);
	},

	componentDidMount() {
		if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
			// Listen to route focus changes
			// Should be a better way to do this...
			this.refs.navRef.refs.navRef.navigationContext.addListener('willfocus', (event) => {
				const route = event.data.route;

				// Make sure renders/card refreshes are only happening when in home route
				if (route.id === "Home") {
					this._resumeTimeout();
				} else {
					this._pauseTimeout();
				}
			});

			// Listen to back button on Android
			BackAndroid.addEventListener('hardwareBackPress', () => {
				var route = this.refs.navRef.refs.navRef.getCurrentRoutes().pop();

				if(route.id === "Home") {
					BackAndroid.exitApp();
					return false;
					
				} else {
					this.refs.navRef.refs.navRef.pop();
					return true;
				}
			});
		}
		else {
			// Pause/resume timeouts
			this.refs.navRef.navigationContext.addListener('didfocus', (event) => {
				const route = event.data.route;

				// Make sure renders/card refreshes are only happening when in home route
				if (route.id === undefined) { //undefined is foxusing "Home"... weird I know
					this._resumeTimeout();
				} else {
					this._pauseTimeout();
				}
			});

			// Make all back buttons use text "Back"
			this.refs.navRef.navigationContext.addListener('willfocus', (event) => {
				const route = event.data.route;
				route.backButtonTitle = "Back";
			});
		}
	},

	componentWillUnmount() {
		AppState.removeEventListener('change', this.handleAppStateChange);
		this._pauseTimeout();
	},

	newTimeout: function(key, callback, delay) {
		timers[key] = (new Timer(callback, delay));
	},

	_pauseTimeout: function() {
		for (var key in timers) {
			timers[key].pause();
		}
	},

	_resumeTimeout: function() {
		for (var key in timers) {
			timers[key].resume();
		}
	},

	render: function() {

		if (general.platformIOS()) {
			StatusBar.setBarStyle('light-content');
		}

		if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
			return (
				<NavigationBarWithRouteMapper
					ref="navRef"
					route={{id: 'Home', name: 'Home', title: 'now@ucsandiego'}}
					renderScene={this.renderScene}
				/>
			);
		} else {
			return (
				<NavigatorIOS
					initialRoute={{ 
						component: Home, 
						title: AppSettings.APP_NAME, 
						passProps: {
							isSimulator: this.props.isSimulator,
							new_timeout: this.newTimeout,
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
			case 'Home': 				return (<Home route={route} navigator={navigator} new_timeout={this.newTimeout}/>);
			case 'ShuttleStop': 		return (<ShuttleStop route={route} navigator={navigator} />);
			case 'SurfReport': 			return (<SurfReport route={route} navigator={navigator} />);
			case 'TopStoriesDetail': 	return (<TopStoriesDetail route={route} navigator={navigator} />);
			case 'EventDetail': 		return (<EventDetail route={route} navigator={navigator} />);
			case 'WebWrapper': 			return (<WebWrapper route={route} navigator={navigator} />);
			case 'WelcomeWeekView': 	return (<WelcomeWeekView route={route} navigator={navigator} />);
			case 'DestinationDetail': 	return (<DestinationDetail route={route} navigator={navigator} />);
			default: 					return (<Home route={route} navigator={navigator} new_timeout={this.newTimeout}/>);
		}
	},

	handleAppStateChange(currentAppState) {
		if (currentAppState === 'active') {
			this._resumeTimeout();
		}
		else if(currentAppState === 'background') {
			this._pauseTimeout();
		}
	},
});

AppRegistry.registerComponent('nowucsandiego', () => nowucsandiego);