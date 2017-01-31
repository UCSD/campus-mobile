import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import DiningService from '../../services/diningService';
import DiningList from './DiningList';
import DiningListView from './DiningListView';
import LocationRequiredContent from '../common/LocationRequiredContent';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const map = require('../../util/map');
const general = require('../../util/general');

class DiningCard extends CardComponent {

	constructor(props) {
		super(props);

		this.diningCardMaxResults = 4;

		this.state = {
			diningDataLoaded: false,
			diningRenderAllRows: false,
		};
	}

	componentDidMount() {
		this.refresh(this.props.location);
	}

	componentWillReceiveProps(nextProps) {
		// if we have a new location, refresh using that location
		if (!this.props.location
				|| (nextProps.location &&
					(nextProps.location.coords.latitude !== this.props.location.coords.latitude
						|| nextProps.location.coords.longitude !== this.props.location.coords.longitude))) {
			this.refresh(nextProps.location);
		}
	}

	render() {
		return (
			<Card id="dining" title="Dining">
				{ this.renderContent() }
			</Card>
		);
	}

	renderContent() {
		if (this.props.locationPermission !== 'authorized') {
			return <LocationRequiredContent />;
		}

		if (!this.state.diningDataLoaded) {
			return null;
		}

		return (
			<View style={css.dining_card}>
				<View style={css.dc_locations}>
					<DiningList data={this.state.diningData} navigator={this.props.navigator} limitResults={this.diningCardMaxResults} />
				</View>
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoDiningListView(this.state.diningData)}>
					<View style={css.events_more}>
						<Text style={css.events_more_label}>View All Locations</Text>
					</View>
				</TouchableHighlight>
			</View>
		);
	}

	refresh(location) {
		DiningService.FetchDining()
		.then((responseData) => {

			responseData = responseData.GetDiningInfoResult;

			if (location) {
				// Calc distance from dining locations
				for (var i = 0; responseData.length > i; i++) {
					var distance = map.getDistance(location.coords.latitude, location.coords.longitude, responseData[i].coords.lat, responseData[i].coords.lon);
					if (distance) {
						responseData[i].distance = distance;
					} else {
						responseData[i].distance = 100000000;
					}

					responseData[i].distanceMiles = general.convertMetersToMiles(distance);
					responseData[i].distanceMilesStr = general.getDistanceMilesStr(responseData[i].distanceMiles);
				}

				// Sort dining locations by distance
				responseData.sort(general.sortNearbyMarkers);
			}

			this.setState({
				diningData: responseData,
				diningDataLoaded: true
			});
		})
		.catch(logger.error)
		.done();
	}

	gotoDiningListView() {
		Actions.DiningListView({ data: this.state.diningData });
	}
}
function mapStateToProps(state, props) {
	return {
		location: state.location.position,
		locationPermission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(DiningCard);
