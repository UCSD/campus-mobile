import React from 'react';
import {
	Alert
} from 'react-native';
import { connect } from 'react-redux';
import TimerMixin from 'react-timer-mixin';
import Permissions from 'react-native-permissions';
import { refreshLocation } from '../actions/location';

const GeoLocationContainer = React.createClass({
	mixins: [TimerMixin],

	componentDidMount() {
		this.setTimeout(
      this.updateLocation,
      this.permissionUpdateInterval
    );
	},

	permissionUpdateInterval: 1 * 65 * 1000,

	updateLocation() {
		// Get location permission status on Android
		Permissions.getPermissionStatus('location')
			.then(response => {
				if (response === 'authorized') {
					refreshLocation();
				}
			});
	},

	alertForLocationPermission() {
		Alert.alert(
			'Allow this app to access your location?',
			'We need access so you can get nearby information.',
			[
				{ text: 'No', onPress: () => {} },
				{ text: 'Yes', onPress: this._requestPermission }
			]
		);
	},

	render() {
		return null;
	}
});

module.exports = connect()(GeoLocationContainer);
