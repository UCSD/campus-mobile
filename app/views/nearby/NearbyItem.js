import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import Icon from 'react-native-vector-icons/FontAwesome';

const css = require('../../styles/css');
const general = require('../../util/general');

export default class NearbyItem extends React.Component {

	gotoNavigationApp(destinationLat, destinationLon) {
		const destinationURL = general.getDirectionsURL('walk', destinationLat, destinationLon );
		general.openURL(destinationURL);
	}

	render() {
		const data = this.props.data;

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoNavigationApp(data.mkrLat, data.mkrLong)}>
				<View style={css.destinationcard_marker_row}>
					<Icon name="map-marker" size={30} color={this.props.color} />
					<Text style={css.destinationcard_marker_label}>{data.title}</Text>
				</View>
			</TouchableHighlight>
		);
	}
}
