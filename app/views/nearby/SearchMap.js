import React, { PropTypes } from 'react';
import MapView from 'react-native-maps';
import css from '../../styles/css';

const SearchMap = ({ location, selectedResult, hideMarker }) => (
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
		style={css.nearby_map_container}
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
		{(selectedResult && !hideMarker) ? (
			<MapView.Marker
				coordinate={{
					latitude: selectedResult.mkrLat,
					longitude: selectedResult.mkrLong
				}}
				title={selectedResult.title}
				description={selectedResult.description}
				identifier={selectedResult.title}
			>
				{/*<MapView.Callout style={{ width: 100 }} >
					<View style={{ flex: 1, alignItems: 'flex-start', flexDirection: 'row' }}>
						<Text style={{width: 70}} >{this.state.selectedResult.title}</Text>
						<TouchableHighlight style={{ width: 30 }} >
							<Icon name="location-arrow" size={20} />
						</TouchableHighlight>
					</View>
				</MapView.Callout>*/}
			</MapView.Marker>
			) : (null)}
	</MapView>
);

SearchMap.propTypes = {
	location: PropTypes.object,
	selectedResult: PropTypes.object,
	hideMarker: PropTypes.boolean,
};

SearchMap.defaultProps = {
	hideMarker: false
};

export default SearchMap;
