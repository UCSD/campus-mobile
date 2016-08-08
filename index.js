/*
 * This file will be the starting off point for iOS and Android
 *  - commonization is now complete for iOS, index.ios.js has been removed
 *  - commonization is still underway for Android, index.android.js should still be used for the time being
 */

'use strict';

import React from 'react';
import {
	AppRegistry,
	NavigatorIOS,
	Navigator,
	StatusBar
} from 'react-native';

var Realm = 		require('realm');

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

	realm: null,
	AppSettings: null,

	migrationGeneric: function(oldRealm, newRealm) {},

	componentWillMount: function() {

		// Realm DB Init
		logger.log('Realm Schema Version: ' + Realm.schemaVersion(Realm.defaultPath));
		this.realm = new Realm({ schema: [AppSettings.DB_SCHEMA], schemaVersion: 2, migration: this.migrationGeneric });
		this.AppSettings = this.realm.objects('AppSettings');

		if (this.AppSettings.length === 0) {
			this.realm.write(() => {
				this.realm.create('AppSettings', { id: 1 });
			});
		}
	},

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