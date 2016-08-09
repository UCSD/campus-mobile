'use strict';

import React from 'react';
import {
	AppRegistry,
	NavigatorIOS,
	Navigator,
	StatusBar
} from 'react-native';

var logger = 		require('./app/util/logger');
var general = 		require('./app/util/general');
var AppSettings = 	require('./app/AppSettings');

var Home, EventDetail, TopStoriesDetail, ShuttleStop, ShuttleStop2, WeatherForecast, SurfReport, DestinationSearch;

Home = require('./app/views/Home');

if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
	
	// SHUTTLE
	ShuttleStop = 				require('./app/views/ShuttleStop');
}


var nowucsandiego = React.createClass({

	render: function() {

		StatusBar.setBarStyle('light-content');

		if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
			return (
				<Navigator initialRoute={{id: 'Home', name: 'Home'}} renderScene={this.renderScene} />
			);
		} else {
			return (
				<NavigatorIOS
					initialRoute={{ component: Home, title: AppSettings.APP_NAME, passProps: { isSimulator: this.props.isSimulator }}}
					style={{flex: 1}}
					tintColor='#FFFFFF'
					barTintColor='#006C92'
					titleTextColor='#FFFFFF'
					navigationBarHidden={false}
					translucent={true} />
			);
		}

	},

	renderScene: function(route, navigator, index, navState) {

		switch (route.id) {
			case 'Home': 					return (<Home route={route} navigator={navigator} isSimulator={this.props.isSimulator} />);
			case 'ShuttleStop': 			return (<ShuttleStop route={route} navigator={navigator} isSimulator={this.props.isSimulator} />);
			default: 						return (<Home route={route} navigator={navigator} />);
		}
	},


});

AppRegistry.registerComponent('nowucsandiego', () => nowucsandiego);