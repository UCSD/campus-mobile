import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import NearbyItem from './NearbyItem';
import Icon from 'react-native-vector-icons/FontAwesome';

var css = require('../../styles/css');
var logger = require('../../util/logger');
var general = require('../../util/general');

const GoogleAPIAvailability = 	require('react-native-google-api-availability-bridge');
var MapView = require('react-native-maps');
var nearbyCounter;

export default class NearbyMap extends React.Component {

	constructor(props) {
		super(props);

		this.state = {};
	}

	render() {
		return(
			<View style={css.destinationcard_map_container}>
				{this.props.nearbyAnnotations && this.props.updatedGoogle && this.props.getCurrentPosition('lat') ? (

					<MapView
						style={css.destinationcard_map}
						loadingEnabled={true}
						loadingIndicatorColor={'#666'}
						loadingBackgroundColor={'#EEE'}
						showsUserLocation={true}
						mapType={'standard'}
						initialRegion={{
							latitude: this.props.getCurrentPosition('lat'),
							longitude: this.props.getCurrentPosition('lon'),
							latitudeDelta: this.props.nearbyLatDelta,
							longitudeDelta: this.props.nearbyLonDelta,
						}}>
							{this.props.nearbyAnnotations.map((marker, index) => (
								<MapView.Marker
									pinColor={this.props.colors[index]}
									coordinate={marker.coords}
									title={marker.title}
									description={marker.description}
									key={index}
								/>
							))}
					</MapView>
				) : null }

				{!this.props.updatedGoogle ? (
					<View>
					<Text>Please update Google Play Services and restart app to view map.</Text>
					<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => GoogleAPIAvailability.openGooglePlayUpdate()}>
						<View style={css.eventdetail_readmore_container}>
							<Text style={css.eventdetail_readmore_text}>Update</Text>
						</View>
					</TouchableHighlight>
					</View>
					) : null}

			</View>
			);
	}
}