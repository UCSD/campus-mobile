import React from 'react';
import {
	View,
	ListView,
} from 'react-native';
import { connect } from 'react-redux';

import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import NearbyList from './NearbyList';
import NearbyMap from './NearbyMap';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const shuttle = require('../../util/shuttle');
const AppSettings = 		require('../../AppSettings');
const general = require('../../util/general');

// UCSD Nodes
const ucsd_nodes = 		require('../../json/ucsd_nodes.json');

const fiveRandomColors = general.getRandomColorArray(5);

class NearbyCard extends CardComponent {

	constructor(props) {
		super(props);

		this.state = {
			nodePreviousLat: null,
			nodePreviousLon: null,
			nearbyMarkersLoaded: false,
			nearbyMaxResults: 5,
			nearbyAnnotations: null,
			nearbyLatDelta: 0.02,
			nearbyLonDelta: 0.02,
			nearbyMarkersFull: null,
			nearbyMarkersPartial: null,
			nearbyInvalidated: false,
		};
	}

	componentDidMount() {
		this.refresh();
	}

	shouldComponentUpdate() {
		this.refresh();
		if (this.state.nearbyInvalidated) {
			this.state.nearbyInvalidated = false;
			return true;
		}
		else {
			return false;
		}
	}

	// Updates which predesignated node region the user is in
	refresh() {
		const currentLat = this.props.currentPosition.coords.latitude;
		const currentLon = this.props.currentPosition.coords.longitude;

		// Determine if location has changed since last run, skip if con
		if ((currentLat !== this.state.nodePreviousLat) || (currentLon !== this.state.nodePreviousLon)) {
			let closestNode = 0;
			let closestNodeDistance = 100000000;

			for (let i = 0; ucsd_nodes.length > i; i++) {
				const nodeDist = shuttle.getDistance(currentLat, currentLon, ucsd_nodes[i].lat, ucsd_nodes[i].lon);

				if (nodeDist < closestNodeDistance) {
					closestNodeDistance = nodeDist;
					closestNode = ucsd_nodes[i].id;
				}
			}

			const NODE_MODULES_URL = AppSettings.NODE_MARKERS_BASE_URL + 'ucsd_node_' + closestNode + '.json';

			fetch(NODE_MODULES_URL, {
				method: 'GET',
			})
			.then((response) => response.json())
			.then((responseData) => {
				this.parseNodeRegion(responseData);
			})
			.catch((error) => {
				logger.log('ERR: loadNodeRegion: ' + error);
			})
			.done();

			this.setState({
				nodePreviousLat: currentLat,
				nodePreviousLon: currentLon
			});
		}
		else {

		}
	}

	parseNodeRegion(ucsd_node) {
		// Calc distance from markers
		for (let i = 0; ucsd_node.length > i; i++) {
			ucsd_node[i].distance = shuttle.getDistance(this.props.currentLocation.coords.latitude, this.props.coords.longitude, ucsd_node[i].mkrLat, ucsd_node[i].mkrLong);
		}

		ucsd_node.sort(general.sortNearbyMarkers);
		const nodeDataFull = ucsd_node;
		const nodeDataPartial = ucsd_node.slice(0, this.state.nearbyMaxResults);

		const dsFull = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
		const dsPartial = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

		const nearbyAnnotations = [];
		for (let i = 0; ucsd_node.length > i && this.state.nearbyMaxResults > i; i++) {
			if (this.state.nearbyMaxResults === i + 1) {
				const distLatLon = Math.sqrt(Math.pow(Math.abs(this.props.getCurrentPosition('lat') - ucsd_node[i].mkrLat), 2) + Math.pow(Math.abs(this.props.getCurrentPosition('lon') - ucsd_node[i].mkrLong), 2));
				this.setState({
					nearbyLatDelta: distLatLon * 2,
					nearbyLonDelta: distLatLon * 2
				});
			}

			const newAnnotations = {};

			newAnnotations.coords = {
				latitude: parseFloat(ucsd_node[i].mkrLat),
				longitude: parseFloat(ucsd_node[i].mkrLong)
			};

			newAnnotations.latitude = parseFloat(ucsd_node[i].mkrLat);
			newAnnotations.longitude = parseFloat(ucsd_node[i].mkrLong);
			newAnnotations.title = ucsd_node[i].title;
			newAnnotations.description = ucsd_node[i].description;
			nearbyAnnotations.push(newAnnotations);
		}
		this.setState({
			nearbyAnnotations,
			nearbyMarkersFull: dsFull.cloneWithRows(nodeDataFull),
			nearbyMarkersPartial: dsPartial.cloneWithRows(nodeDataPartial),
			nearbyMarkersLoaded: true,
			nearbyInvalidated: true
		});
	}

	render() {
		return (
			<Card title="Nearby">
				<View>
					<NearbyMap
						nearbyAnnotations={this.state.nearbyAnnotations}
						updatedGoogle={this.props.updatedGoogle}
						location={this.props.currentPosition}
						nearbyLonDelta={this.state.nearbyLonDelta}
						nearbyLatDelta={this.state.nearbyLatDelta}
						colors={fiveRandomColors}
					/>
					<View style={css.events_list}>
						{this.state.nearbyMarkersLoaded ? (
							<NearbyList
								data={this.state.nearbyMarkersPartial}
								colors={fiveRandomColors}
								getCurrentPosition={(latlon) => this.props.getCurrentPosition(latlon)}
								navigator={this.props.navigator}
							/>
						) : null}
					</View>
				</View>
			</Card>
		);
	}
}

function mapStateToProps(state, props) {
	return {
		currentPosition: state.location.position
	};
}

module.exports = connect(mapStateToProps)(NearbyCard);
