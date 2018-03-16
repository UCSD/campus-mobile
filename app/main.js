import React, { Component } from 'react';
import {
	View,
	StatusBar
} from 'react-native';

import css from './styles/css';
import general from './util/general';

// PUSH
import PushNotificationContainer from './containers/pushNotificationContainer';

// ROUTER
import Router from './navigation/Router';

if (general.platformIOS()) {
	StatusBar.setBarStyle('light-content');
} else if (general.platformAndroid()) {
	StatusBar.setBackgroundColor('#101d32', false);
}

const Main = () => (
	<View style={css.flex}>
		<PushNotificationContainer />
		<Router />
	</View>
);

export default Main;
