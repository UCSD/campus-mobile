import React from 'react';
import {
	View,
	Text,
	ActivityIndicator,
	StyleSheet,
	AppState
} from 'react-native';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import ShuttleCard from './ShuttleCard';
import ShuttleStop from './ShuttleStop';
import LocationRequiredContent from '../common/LocationRequiredContent';
import general, { getPRM, getMaxCardWidth, round } from '../../util/general';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const shuttle = require('../../util/shuttle');
const map = require('../../util/map');
const shuttle_routes = require('../../json/shuttle_routes_master.json');

class ShuttleCardContainer extends CardComponent {
	componentDidMount() {
		logger.log('Card Mounted: Shuttle');

		AppState.addEventListener('change', this._handleAppStateChange);
	}

	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange);
	}

	_handleAppStateChange = (currentAppState) => {
		this.setState({ currentAppState });

		// check TTL and refresh weather data if needed
		if (currentAppState === 'active') {

		}
	}

	render() {
		return (<ShuttleCard
			arrivalData={this.props.arrivalData}
			permission={this.props.locationPermission}
			gotoShuttleStop={this.gotoShuttleStop}
		/>);
	}

	gotoShuttleStop = (stopData, shuttleData) => {
		Actions.ShuttleStop({ stopData, currentPosition: this.props.location, shuttleData });
	}
}

function mapStateToProps(state, props) {
	return {
		location: state.location.position,
		locationPermission: state.location.permission,
		arrivalData: (state.shuttle.closestStop !== -1) ? (state.shuttle.stops[state.shuttle.closestStop].arrivals) : (null),
	};
}

const mapDispatchToProps = (dispatch) => (
	{

	}
);

const ActualShuttleCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(ShuttleCardContainer);

export default ActualShuttleCard;
