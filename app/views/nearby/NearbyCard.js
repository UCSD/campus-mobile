'use strict'

import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';

import Card from '../card/Card'
import CardComponent from '../card/CardComponent'
import NearbyList from './NearbyList';
import NearbyMap from './NearbyMap';

var css = require('../../styles/css');
var logger = require('../../util/logger');
var shuttle = require('../../util/shuttle');
var AppSettings = 		require('../../AppSettings');
var general = require('../../util/general');


// UCSD Nodes
var ucsd_nodes = 		require('../../json/ucsd_nodes.json');
var fiveRandomColors = general.getRandomColorArray(5);

export default class NearbyCard extends CardComponent {

	constructor(props) {
		super(props);

		this.state = {
			nodePreviousLat: null,
			nodePreviousLon: null,
			nearbyMarkersLoaded: false,
			nearbyMaxResults: 5,
			nearbyAnnotations: null,
			nearbyLatDelta: .02,
			nearbyLonDelta: .02,
			nearbyMarkersFull: null,
			nearbyMarkersPartial: null,
			nearbyInvalidated: false,
		}
	}

	componentDidMount() {
		this.refresh();
	}

	shouldComponentUpdate() {
		this.refresh();
		if(this.state.nearbyInvalidated) {
			this.state.nearbyInvalidated = false;
			return true;
		}
		else {
			return false;
		}
	}

	// Updates which predesignated node region the user is in
	refresh() {
		var currentLat = this.props.getCurrentPosition('lat');
		var currentLon = this.props.getCurrentPosition('lon');

		// Determine if location has changed since last run, skip if con
		if ((this.props.getCurrentPosition('lat') !== this.state.nodePreviousLat) ||
			(this.props.getCurrentPosition('lon') !== this.state.nodePreviousLon)) {
			var closestNode = 0;
			var closestNodeDistance = 100000000;

			for (var i = 0; ucsd_nodes.length > i; i++) {
				var nodeDist = shuttle.getDistance(currentLat, currentLon, ucsd_nodes[i].lat, ucsd_nodes[i].lon);

				if (nodeDist < closestNodeDistance) {
					closestNodeDistance = nodeDist;
					closestNode = ucsd_nodes[i].id;
				}
			}

			var NODE_MODULES_URL = AppSettings.NODE_MARKERS_BASE_URL + 'ucsd_node_' + closestNode + '.json';

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
				nodePreviousLat: this.props.getCurrentPosition('lat'),
				nodePreviousLon: this.props.getCurrentPosition('lon')
			});
		}
		else {
			
		}
		
	}

	parseNodeRegion(ucsd_node) {
		// Calc distance from markers
		for (var i = 0; ucsd_node.length > i; i++) {
			ucsd_node[i].distance = shuttle.getDistance(this.props.getCurrentPosition('lat'), this.props.getCurrentPosition('lon'), ucsd_node[i].mkrLat, ucsd_node[i].mkrLong);
		}

		ucsd_node.sort(general.sortNearbyMarkers);
		var nodeDataFull = ucsd_node;
		var nodeDataPartial = ucsd_node.slice(0, this.state.nearbyMaxResults);

		var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
		var dsPartial = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		var farthestMarkerDist;

		var nearbyAnnotations = [];
		for (var i = 0; ucsd_node.length > i && this.state.nearbyMaxResults > i; i++) {
			if (this.state.nearbyMaxResults === i + 1) {
				farthestMarkerDist = ucsd_node[i].distance;
				var distLatLon = Math.sqrt(Math.pow(Math.abs(this.props.getCurrentPosition('lat') - ucsd_node[i].mkrLat), 2) + Math.pow(Math.abs(this.props.getCurrentPosition('lon') - ucsd_node[i].mkrLong), 2));
				this.setState({
					nearbyLatDelta: distLatLon * 2,
					nearbyLonDelta: distLatLon * 2
				});
			}

			var newAnnotations = {};

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
			nearbyAnnotations: nearbyAnnotations,
			nearbyMarkersFull: dsFull.cloneWithRows(nodeDataFull),
			nearbyMarkersPartial: dsPartial.cloneWithRows(nodeDataPartial),
			nearbyMarkersLoaded: true,
			nearbyInvalidated: true
		});
	}

	render() {
		return (
			<Card title='Nearby'>
				<View>
					<NearbyMap nearbyAnnotations={this.state.nearbyAnnotations} 
						updatedGoogle={this.props.updatedGoogle} 
						getCurrentPosition={(latlon) => this.props.getCurrentPosition(latlon)}
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
								navigator={this.props.navigator} />
						) : null}
					</View>
				</View>
			</Card>
		);
	}
}