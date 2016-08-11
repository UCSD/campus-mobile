'use strict';

import React from 'react';
import {
	AppRegistry,
	NavigatorIOS,
	Navigator,
	StatusBar
} from 'react-native';
import NavigationBarWithRouteMapper from './app/views/NavigationBarWithRouteMapper';
import WelcomeWeekView from './app/views/welcomeWeek/WelcomeWeekView';

var logger = 		require('./app/util/logger');
var general = 		require('./app/util/general');
var AppSettings = 	require('./app/AppSettings');

var Home, ShuttleStop, SurfReport, EventDetail, TopStoriesDetail, WebWrapper, DestinationDetail;

Home = require('./app/views/Home');

if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
	ShuttleStop = 			require('./app/views/ShuttleStop');
	SurfReport = 			require('./app/views/weather/SurfReport');
	TopStoriesDetail = 		require('./app/views/topStories/TopStoriesDetail');
	EventDetail = 			require('./app/views/events/EventDetail');
	WebWrapper = 			require('./app/views/WebWrapper');
	DestinationDetail = 	require('./app/views/DestinationDetail');
}


var nowucsandiego = React.createClass({

	getInitialState() {
		return {
			pauseRefresh: false,
		};
	},
	/*
	//check the status of a single permission
	componentDidMount: function() {

		// Listen to route focus changes
		this.refs.navRef.navigationContext.addListener('didfocus', (event) => {
			const route = event.data.route;
			console.log("IOS unFOCUS: " + route.name);

			// Make sure renders/card refreshes are only happening when in home route
			// For some reason route name for home is undefined?
			if(route.name === undefined) {
				console.log("no pause");
				this.setState({pauseRefresh: false});
			}
			else {
				this.setState({pauseRefresh: true});
			}
		});
	},*/

	render: function() {
		StatusBar.setBarStyle('light-content');

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
						passProps: { isSimulator: this.props.isSimulator, 
						pauseRefresh: this.state.pauseRefresh,},
						backButtonTitle: "Back",}}
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