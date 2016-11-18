import React from 'react';
import {
	View,
	TouchableHighlight,
	Text
} from 'react-native';
import { connect } from 'react-redux';

import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import LocationRequiredContent from '../common/LocationRequiredContent';
import SearchBar from './SearchBar';
import SearchMap from './SearchMap';
import SearchResults from './SearchResults';
import NearbyMapView from './NearbyMapView';

import NearbyService from '../../services/nearbyService';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const shuttle = require('../../util/shuttle');
const AppSettings = 		require('../../AppSettings');
const general = require('../../util/general');

class SearchCard extends CardComponent {

	constructor(props) {
		super(props);

		this.state = {
			selectedResult: null,
			searchResults: null,
			selectedInvalidated: true
		};
	}

	componentDidMount() {
	}

	shouldComponentUpdate() {
		/*
		if (this.state.selectedInvalidated) {
			this.state.selectedInvalidated = false;
			return true;
		} else {
			return false;
		}*/
		return true;
	}

	refresh() {
		this.setState({
			selectedInvalidated: true
		});
	}

	updateSearch = (text) => {
		NearbyService.FetchSearchResults(text).then((result) => {
			if (result.results) {
				// Cutoff excess
				if (result.results.length > 5) {
					result.results = result.results.slice(0, 5);
				}

				this.setState({
					searchResults: result.results,
					selectedResult: result.results[0],
					selectedInvalidated: true
				});
			} else {
				// handle no results
			}
		});
	}

	updateSelectedResult = (index) => {
		const newSelect = this.state.searchResults[index];
		this.setState({
			selectedResult: newSelect,
			selectedInvalidated: true
		});
	}

	gotoNearbyMapView() {
		this.props.navigator.push({ id: 'NearbyMapView', title: 'Search', name: 'NearbyMapView', component: NearbyMapView });
	}

	render() {
		return (
			<Card id="map" title="Map">
				{ this.renderContent() }
			</Card>
		);
	}

	renderContent() {
		console.log('UPDATING' + JSON.stringify(this.props.location));
		if (this.props.locationPermission !== 'authorized') {
			return <LocationRequiredContent />;
		}
		return (
			<View>
				<SearchBar
					update={this.updateSearch}
				/>
				<SearchMap
					location={this.props.location}
					selectedResult={this.state.selectedResult}
					style={css.nearby_map_container}
				/>
				{(this.state.searchResults) ? (
					<SearchResults
						results={this.state.searchResults}
						onSelect={(index) => this.updateSelectedResult(index)}
					/>
				) : (null)}
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoNearbyMapView()}>
					<View style={css.events_more}>
						<Text style={css.events_more_label}>View Full Map</Text>
					</View>
				</TouchableHighlight>
			</View>
		);
	}
}

function mapStateToProps(state, props) {
	console.log('MAPPING' + JSON.stringify(state.location.position));
	return {
		location: state.location.position,
		locationPermission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(SearchCard);
