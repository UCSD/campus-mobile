import React from 'react';
import {
	Text,
	AppState,
} from 'react-native';
import { connect } from 'react-redux';
import TimerMixin from 'react-timer-mixin';
import { updateVehicles } from '../actions/shuttle';

const logger = require('../util/logger');
const AppSettings = require('../AppSettings');

const ShuttleLocationContainer = React.createClass({
	mixins: [TimerMixin],
	locationWatch: null,
	permissionUpdateInterval: 6000,

	componentDidMount() {
		// start watch regardless
		this.startLocationWatch();

		AppState.addEventListener('change', this._handleAppStateChange);
	},

	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange);
	},

	_handleAppStateChange(currentAppState) {
		this.setState({ currentAppState, });
		if (currentAppState === 'active') {
			// this.checkLocationPermission();
		}
	},

	startLocationWatch() {
		// fire immediately
		// this.tryUpdateLocation();

		// fire on interval
		this.locationWatch = this.setInterval(
			this.tryUpdateLocation,
			this.permissionUpdateInterval
		);
	},

	tryUpdateLocation() {
		const { dispatch, toggles } = this.props;

		// Update vehicles for every route that is turned on
		Object.keys(toggles).forEach((key, index) => {
			// Update vehicle info if route is turned on
			if (toggles[key]) {
				dispatch(updateVehicles(key));
			}
		});
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
		toggles: state.shuttle.toggles,
		routes: state.shuttle.routes,
		vehicles: state.shuttle.vehicles
	};
}

module.exports = connect(mapStateToProps)(ShuttleLocationContainer);
