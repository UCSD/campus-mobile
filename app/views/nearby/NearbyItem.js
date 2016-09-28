'use strict'

import React from 'react'
import {
	StyleSheet,
	View,
	Text,
	Navigator,
	TouchableHighlight,
	Image,
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

var css = require('../../styles/css');
var general = require('../../util/general');

export default class NearbyItem extends React.Component {

	gotoNavigationApp(destinationLat, destinationLon) {
		var destinationURL = general.getDirectionsURL('walk', destinationLat, destinationLon );
		general.openURL(destinationURL);
	}


	render() {
		var data = this.props.data;

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoNavigationApp(data.mkrLat, data.mkrLong) }>
				<View style={css.destinationcard_marker_row}>
					<Icon name="map-marker" size={30} color={this.props.color} />
					<Text style={css.destinationcard_marker_label}>{data.title}</Text>
				</View>
			</TouchableHighlight>
		);
	}
}