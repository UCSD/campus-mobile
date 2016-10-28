import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import DiningService from '../../services/diningService';
import DiningList from './DiningList';
import DiningListView from './DiningListView';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const shuttle = require('../../util/shuttle');
const general = require('../../util/general');

export default class DiningCard extends CardComponent {

	constructor(props) {
		super(props);

		this.diningCardMaxResults = 4;

		this.state = {
			diningDataLoaded: false,
			diningRenderAllRows: false,
		};
	}

	componentDidMount() {
		this.refresh();
	}

	render() {
		return (
			<Card title="Dining">
				{this.state.diningDataLoaded ? (
					<View style={css.dining_card}>
						<View style={css.dining_card_map}></View>
						<View style={css.dc_locations}>
							<DiningList data={this.state.diningData} navigator={this.props.navigator} limitResults={this.diningCardMaxResults} />
						</View>
						<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningListView(this.state.diningData) }>
							<View style={css.events_more}>
								<Text style={css.events_more_label}>View All Locations</Text>
							</View>
						</TouchableHighlight>
					</View>
				) : null }
			</Card>
		);
	}

	refresh() {
		DiningService.FetchDining()
		.then((responseData) => {
			responseData = responseData.GetDiningInfoResult;

			// Calc distance from dining locations
			for (var i = 0; responseData.length > i; i++) {
				var distance = shuttle.getDistance(this.props.location.coords.latitude, this.props.location.coords.longitude, responseData[i].coords.lat, responseData[i].coords.lon);
				if (distance) {
					responseData[i].distance = distance;
				} else {
					responseData[i].distance = 100000000;
				}

				responseData[i].distanceMiles = general.convertMetersToMiles(distance);
				responseData[i].distanceMilesStr = general.getDistanceMilesStr(responseData[i].distanceMiles);
			}

			// Sort dining locations by distance
			responseData.sort(this.sortNearbyMarkers);

			this.setState({
				diningData: responseData,
				diningDataLoaded: true
			});
		})
		.catch((error) => {
			logger.log('ERR: fetchDiningLocations: ' + error)
		})
		.done();
	}

	gotoDiningListView() {
		this.props.navigator.push({ id: 'DiningListView', name: 'DiningListView', title: 'Dining',  component: DiningListView, data: this.state.diningData });
	}
}