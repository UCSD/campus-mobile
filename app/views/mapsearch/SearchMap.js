import React, { PropTypes } from 'react';
import {
	StyleSheet,
} from 'react-native';
import MapView from 'react-native-maps';
import Icon from 'react-native-vector-icons/FontAwesome';

// NOTE: For some reason MapView-onCalloutPress only works for Android and
// TouchableHighlight-onPress only works for iOS...which is why it's in two places
const SearchMap = ({ location, selectedResult, style, shuttle, vehicles }) => (
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
				const deltaLat = (maxLat - minLat) + 0.02;
				const deltaLong = (maxLong - minLong) + 0.02;

				const midRegion = {
					latitude: midLat,
					longitude: midLong,
					latitudeDelta: deltaLat,
					longitudeDelta: deltaLong,
				};
				MapRef.animateToRegion(midRegion, 1000);
			}
		}}
		style={styles.map_container}
		loadingEnabled={true}
		loadingIndicatorColor={'#666'}
		loadingBackgroundColor={'#EEE'}
		showsUserLocation={true}
		mapType={'standard'}
		initialRegion={{
			latitude: location.coords.latitude,
			longitude: location.coords.longitude,
			latitudeDelta: 0.02,
			longitudeDelta: 0.02
		}}
	>
		{
			(shuttle && (Object.keys(vehicles).length !== 0)) ? (
				// Create MapView.Marker for each vehicle
				Object.keys(vehicles).map((key, index) => {
					const vehicleArray = vehicles[key];

					return vehicleArray.map((vehicle) => (
						<MapView.Marker.Animated
							coordinate={vehicle.animated}
							title={vehicle.name}
							identifier={vehicle.name}
							key={vehicle.name}
						>
							<Icon name={'bus'} size={20} color={'#182B49'} />
						</MapView.Marker.Animated>
						)
					);
				})
			) : (null)
		}
		{
			(shuttle && (Object.keys(vehicles).length !== 0)) ? (
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
							coordinate={{
								latitude: stop.lat,
								longitude: stop.lon
							}}
							title={stop.name}
							identifier={stop.name}
							key={stop.name + key}
							pinColor={'#346994'}
						>
							<Icon style={{ textAlign: 'center', height: 10, width: 10, borderWidth: 1, borderRadius: 5, borderColor: '#346994' }} name={'circle'} color={'white'} size={10} />
						</MapView.Marker>
					);
				})
			) : (null)
		}

		{
			(selectedResult) ? (
				<MapView.Marker
					coordinate={{
						latitude: selectedResult.mkrLat,
						longitude: selectedResult.mkrLong
					}}
					title={selectedResult.title}
					identifier={selectedResult.title}
					key={selectedResult.title}
				/>
			) : (null)
		}
	</MapView>
);

SearchMap.propTypes = {
	location: PropTypes.object,
	selectedResult: PropTypes.object,
};

SearchMap.defaultProps = {
	location: null,
	selectedResult: null,
};

const styles = StyleSheet.create({
	map_container : { ...StyleSheet.absoluteFillObject },
});

export default SearchMap;
