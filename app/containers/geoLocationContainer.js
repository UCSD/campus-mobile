import React from 'react';
import {
	Alert,
	Text
} from 'react-native';
import { connect } from 'react-redux';
import TimerMixin from 'react-timer-mixin';
import Permissions from 'react-native-permissions';
import { updateLocation, setPermission } from '../actions/location';

const logger = require('../util/logger');

const GeoLocationContainer = React.createClass({
	mixins: [TimerMixin],
	permissionUpdateInterval: 1000, // 1 * 65 * 1000,

	componentDidMount() {
		// fire immediately
		this.setTimeout(
			this.getPermission,
			100
		);

		// fire on interval
		this.setInterval(
      this.updateLocation,
      this.permissionUpdateInterval
    );
	},

	getPermission() {
		Permissions.requestPermission('location')
			.then(response => {
				// dispatch response
				logger.log(response);
				this.props.dispatch(setPermission(response));

				// if authorized, act
				if (response === 'authorized') {
					this.updateLocation();
				}
			})
			.catch(logger.error);
	},

	updateLocation() {
		const { dispatch, permission } = this.props;
		if (permission !== 'authorized') return;

		// request update
		dispatch(updateLocation());
	},

	alertForLocationPermission() {
		Alert.alert(
			'Allow this app to access your location?',
			'We need access so you can get nearby information.',
			[
				{ text: 'No', onPress: () => {} },
				{ text: 'Yes', onPress: this.getPermission() }
			]
		);
	},

	render() {
		return (
			<Text>Permission: {this.props.permission}, Location: {this.props.position.coords.latitude}, {this.props.position.coords.longitude}</Text>
		);
	}
});

function mapStateToProps(state, props) {
	return {
		position: state.location.position,
		permission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(GeoLocationContainer);
