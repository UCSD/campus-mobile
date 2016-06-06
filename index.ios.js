'use strict';

import React from 'react';
import {
	AppRegistry,
	NavigatorIOS,
	StatusBar
} from 'react-native';

var Realm = 		require('realm');

var logger = 		require('./app/util/logger');
var AppSettings = 	require('./app/AppSettings');
var Home = 			require('./app/views/Home');


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
	},
});

AppRegistry.registerComponent('nowucsandiego', () => nowucsandiego);