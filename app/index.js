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
var AppSettings = 			require('./AppSettings'),
	general = 				require('./util/general'),
	logger = 				require('./util/logger'),

// VIEWS
	Home = 					require('./views/Home'),
	ShuttleStop = 			require('./views/ShuttleStop'),
	SurfReport = 			require('./views/weather/SurfReport'),
	DiningList = 			require('./views/dining/DiningList'),
	DiningDetail = 			require('./views/dining/DiningDetail'),
	DiningNutrition = 		require('./views/dining/DiningNutrition'),
	NewsDetail = 			require('./views/news/NewsDetail'),
	EventDetail = 			require('./views/events/EventDetail'),
	WebWrapper = 			require('./views/WebWrapper');

import WelcomeWeekView from './views/welcomeWeek/WelcomeWeekView';
import EventListView from './views/events/EventListView';
import NewsListView from './views/news/NewsListView';
import FeedbackView from './views/FeedbackView';

// NAV
import NavigationBarWithRouteMapper from './views/NavigationBarWithRouteMapper';
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

	this.do = function() {
		clearTimeout(timerId);
		callback();
	}

	this.getID = function() {
		return timerId;
	};

	this.resume();
}
var timers = {};

var nowucsandiego = React.createClass({

	mixins: [TimerMixin],

	getInitialState() {
		return {
			inHome: true,
		};
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
					this.setState({inHome: true});
					this._resumeTimeout();
				} else {
					this.setState({inHome: false});
					this._pauseTimeout();
				}
			});

			// Listen to back button on Android
			BackAndroid.addEventListener('hardwareBackPress', () => {
				//console.log(util.inspect(this.refs.navRef.refs.navRef.getCurrentRoutes()));
				//var route = this.refs.navRef.refs.navRef.getCurrentRoutes()[0];

				if(this.state.inHome) {
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
					this.setState({inHome: true});
					this._resumeTimeout();
				} else {
					this.setState({inHome: false});
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

	doTimeout: function() {
		for (var key in timers) {
			timers[key].do();
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
							do_timeout: this.doTimeout
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
			case 'Home': 				return (<Home route={route} navigator={navigator} new_timeout={this.newTimeout} do_timeout={this.doTimeout}/>);
			case 'ShuttleStop': 		return (<ShuttleStop route={route} navigator={navigator} />);
			case 'SurfReport': 			return (<SurfReport route={route} navigator={navigator} />);
			case 'DiningList': 			return (<DiningList route={route} navigator={navigator} />);
			case 'DiningDetail': 		return (<DiningDetail route={route} navigator={navigator} />);
			case 'DiningNutrition': 	return (<DiningNutrition route={route} navigator={navigator} />);
			case 'NewsDetail': 			return (<NewsDetail route={route} navigator={navigator} />);
			case 'EventDetail': 		return (<EventDetail route={route} navigator={navigator} />);
			case 'WebWrapper': 			return (<WebWrapper route={route} navigator={navigator} />);
			case 'WelcomeWeekView': 	return (<WelcomeWeekView route={route} navigator={navigator} />);
			case 'EventListView': 		return (<EventListView route={route} navigator={navigator} />);
			case 'NewsListView': 	return (<NewsListView route={route} navigator={navigator} />);
			case 'FeedbackView': 	return (<FeedbackView route={route} navigator={navigator} />);
			default: 					return (<Home route={route} navigator={navigator} new_timeout={this.newTimeout} do_timeout={this.doTimeout}/>);
		}
	},

	handleAppStateChange(currentAppState) {
		if (currentAppState === 'active') {
			if(this.state.inHome) {
				this._resumeTimeout();
			}
		}
		else if(currentAppState === 'background') {
			this._pauseTimeout();
		}
	},
});

module.exports = nowucsandiego;