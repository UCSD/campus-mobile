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
const AppSettings = require('../AppSettings');

const GeoLocationContainer = React.createClass({
	mixins: [TimerMixin],

	componentDidMount() {
		const { dispatch } = this.props;

		// preload permission and dispatch immediately
		Permissions.getPermissionStatus('location')
			.then(response => {
				dispatch(setPermission(response));

				if (response === 'undetermined') {
					// fire immediately on different thread
					this.setTimeout(
						this.getPermission(),
						100
					);
				}
			});

		// start watch regardless
		this.startLocationWatch();
	},

	getSoftPermission() {
		logger.log('calling alert');
		Alert.alert(
			'Allow this app to access your location?',
			'We need access so you can get nearby information.',
			[
				{ text: 'No', onPress: () => {} },
				{ text: 'Yes', onPress: this.getPermission }
			]
		);
	},

	getPermission() {
		Permissions.requestPermission('location')
			.then(response => {
				// dispatch response
				this.props.dispatch(setPermission(response));

				// if authorized, act
				if (response === 'authorized') {
					this.startLocationWatch();
				}
			})
			.catch(logger.error);
	},

	locationWatch: null,
	permissionUpdateInterval: 5000, // 1 * 65 * 1000,

	startLocationWatch() {
		// fire immediately
		this.tryUpdateLocation();

		// fire on interval
		this.locationWatch = this.setInterval(
      this.tryUpdateLocation,
      this.permissionUpdateInterval
    );
	},

	tryUpdateLocation() {
		const { dispatch, permission } = this.props;
		// never call service if we don't have permission
		if (permission !== 'authorized') return;

		// request update
		dispatch(updateLocation());
	},

	render() {
		if (!AppSettings.DEBUG_ENABLED) return null;

		if (this.props.permission !== 'authorized') {
			return (
				<Text>Permission: {this.props.permission}</Text>
			);
		}

		return (
			<Text>
				Location: {this.props.position.coords.latitude}, {this.props.position.coords.longitude}
				Timestamp: {this.props.position.timestamp}
			</Text>
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
