import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

const css = require('../../styles/css');

const GoogleAPIAvailability = 	require('react-native-google-api-availability-bridge');
const MapView = require('react-native-maps');

export default class NearbyMap extends React.Component {

	constructor(props) {
		super(props);

		// setup our inital map values
		this.state = {
			region: {
				latitude: this.props.location.coords.latitude,
				longitude: this.props.location.coords.longitude,
				latitudeDelta: this.props.nearbyLatDelta,
				longitudeDelta: this.props.nearbyLonDelta
			}
		};
	}

	componentWillReceiveProps(nextProps) {
		// if we have a new location, refresh region using that location
		if (!this.props.location
				|| (nextProps.location &&
					(nextProps.location.coords.latitude !== this.props.location.coords.latitude
						|| nextProps.location.coords.longitude !== this.props.location.coords.longitude))) {
			this.refreshRegion(nextProps.location);
		}
	}

	onRegionChange(region) {
		this.setState({ region });
	}

	refreshRegion(location) {
		this.map.animateToRegion(//new MapView.AnimatedRegion(
			{
				latitude: location.coords.latitude,
				longitude: location.coords.longitude,
				latitudeDelta: this.props.nearbyLatDelta,
				longitudeDelta: this.props.nearbyLonDelta,
			});
	}

	render() {
		return (
			<View style={css.destinationcard_map_container}>
				{this.props.nearbyAnnotations && this.props.updatedGoogle && this.props.location ? (

					<MapView
						ref={ref => { this.map = ref; }}
						style={css.destinationcard_map}
						loadingEnabled={true}
						loadingIndicatorColor={'#666'}
						loadingBackgroundColor={'#EEE'}
						showsUserLocation={true}
						mapType={'standard'}
						initalRegionregion={this.state.region}
						onRegionChange={region => this.onRegionChange(region)}
					>
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
