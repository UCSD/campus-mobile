import React, { PropTypes } from 'react';
import { Text, TouchableHighlight, View } from 'react-native';
import MapView from 'react-native-maps';
import Icon from 'react-native-vector-icons/FontAwesome';

import general from '../../util/general';

// NOTE: For some reason MapView-onCalloutPress only works for Android and
// TouchableHighlight-onPress only works for iOS...which is why it's in two places
const SearchMap = ({ location, selectedResult, hideMarker, style, shuttle, vehicles }) => (
	<MapView
		ref={(MapRef) => {
			if ( MapRef != null && selectedResult != null ) {
				// Calculate center region and animate to it
				const midLat = (location.coords.latitude + selectedResult.mkrLat) / 2;
				const midLong = (location.coords.longitude + selectedResult.mkrLong) / 2;
				const minLat = (location.coords.latitude < selectedResult.mkrLat) ? location.coords.latitude : selectedResult.mkrLat;
				const minLong = (location.coords.longitude < selectedResult.mkrLong) ? location.coords.longitude : selectedResult.mkrLong;
				const maxLat = (location.coords.latitude > selectedResult.mkrLat) ? location.coords.latitude : selectedResult.mkrLat;
				const maxLong = (location.coords.longitude > selectedResult.mkrLong) ? location.coords.longitude : selectedResult.mkrLong;
				const deltaLat = (maxLat - minLat) + 0.002;
				const deltaLong = (maxLong - minLong) + 0.002;

				const midRegion = {
					latitude: midLat,
					longitude: midLong,
					latitudeDelta: deltaLat,
					longitudeDelta: deltaLong,
				};
				MapRef.animateToRegion(midRegion, 1000);
			}
		}}
		style={style}
		loadingEnabled={true}
		loadingIndicatorColor={'#666'}
		loadingBackgroundColor={'#EEE'}
		showsUserLocation={true}
		mapType={'standard'}
		region={{
			latitude: location.coords.latitude,
			longitude: location.coords.longitude,
			latitudeDelta: 0.02,
			longitudeDelta: 0.02
		}}
		onCalloutPress={
			() => gotoNavigationApp(selectedResult.mkrLat, selectedResult.mkrLong)
		}
	>
		{(selectedResult && !hideMarker) ? (
			<MapView.Marker
				ref={(MarkRef) => {
					//console.log("MARKER: " + selectedResult.title);
					if (MarkRef != null) {
						//MarkRef.showCallout();
					}
				}}
				coordinate={{
					latitude: selectedResult.mkrLat,
					longitude: selectedResult.mkrLong
				}}
				title={selectedResult.title}
				description={selectedResult.description}
				identifier={selectedResult.title}
			>
				<MapView.Callout style={{ width: 100 }} >
					<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => gotoNavigationApp(selectedResult.mkrLat, selectedResult.mkrLong)}>
						<View style={{ flex: 1, alignItems: 'center', flexDirection: 'row', flexWrap: 'wrap' }}>
							<Text style={{ flex: 0.8 }}>{selectedResult.title}</Text>
							<Icon style={{ flex:0.2 }} name={'location-arrow'} size={20} />
						</View>
					</TouchableHighlight>
				</MapView.Callout>
			</MapView.Marker>
			) : (null)}

		{
			// Create MapView.Marker for each shuttle stop
			Object.keys(shuttle).map((key, index) => {
				const stop = shuttle[key];
				if ((Object.keys(stop.routes).length === 0 && stop.routes.constructor === Object) ||
					// Hide Airport stops
					stop.routes['89']) {
					return null;
				}

				return (
					<MapView.Marker
						ref={(MarkRef) => {
							//console.log("MARKER: " + selectedResult.title);
							if (MarkRef != null) {
								//MarkRef.showCallout();
							}
						}}
						coordinate={{
							latitude: stop.lat,
							longitude: stop.lon
						}}
						title={stop.name}
						identifier={stop.name}
					>
						<Icon style={{ flex:0.2 }} name={'flag'} size={20} />
						<MapView.Callout style={{ width: 100 }} >
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'}>
								<View style={{ flex: 1, alignItems: 'center', flexDirection: 'column', flexWrap: 'wrap' }}>
									<Text>{stop.name}</Text>
								</View>
							</TouchableHighlight>
						</MapView.Callout>
					</MapView.Marker>
				);
			})
		}

		{
			// Create MapView.Marker for each vehicle
			Object.keys(vehicles).map((key, index) => {
				const vehicleArray = vehicles[key];

				return vehicleArray.map((vehicle) => (
					<MapView.Marker.Animated
						ref={(MarkRef) => {
							// console.log("MARKER: " + selectedResult.title);
							if (MarkRef != null) {
								// MarkRef.showCallout();
							}
						}}
						coordinate={vehicle.animated}
						title={vehicle.name}
						identifier={vehicle.name}
					>
						<Icon style={{ flex:0.2 }} name={'bus'} size={20} />
						<MapView.Callout style={{ width: 100 }} >
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'}>
								<View style={{ flex: 1, alignItems: 'center', flexDirection: 'column', flexWrap: 'wrap' }}>
									<Text>{vehicle.name}</Text>
								</View>
							</TouchableHighlight>
						</MapView.Callout>
					</MapView.Marker.Animated>
					)
				);
			})
		}
	</MapView>
);

SearchMap.propTypes = {
	location: PropTypes.object,
	selectedResult: PropTypes.object,
	hideMarker: PropTypes.bool,
};

SearchMap.defaultProps = {
	location: null,
	selectedResult: null,
	hideMarker: false
};

const gotoNavigationApp = (destinationLat, destinationLon) => {
	const destinationURL = general.getDirectionsURL('walk', destinationLat, destinationLon );
	general.openURL(destinationURL);
};

export default SearchMap;
