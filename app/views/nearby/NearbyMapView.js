import React from 'react';
import {
	View,
	ListView,
	Dimensions,
	TouchableHighlight,
	Text
} from 'react-native';

import SlidingUpPanel from 'react-native-sliding-up-panel';
import SearchBar from './SearchBar';
import NearbyService from '../../services/nearbyService';
import Icon from 'react-native-vector-icons/FontAwesome';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const shuttle = require('../../util/shuttle');
const AppSettings = 		require('../../AppSettings');
const general = require('../../util/general');
const MapView = require('react-native-maps');

var deviceHeight = Dimensions.get('window').height;
var deviceWidth = Dimensions.get('window').width;

var MAXIMUM_HEIGHT = deviceHeight - 100;
var MINUMUM_HEIGHT = 80;

export default class NearbyMapView extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			initialRegion: null,
			searchResults: null,
			selectedResult: null,
			sliding: false,
		};
	}

	componentWillMount() {
		navigator.geolocation.getCurrentPosition(
			(position) => {
				this.setState({
					initialRegion: {
						latitude: position.coords.latitude,
						longitude: position.coords.longitude,
						latitudeDelta: 0.02,
						longitudeDelta: 0.02
					}
				});
			},
			null,
			{ enableHighAccuracy: true, timeout: 20000, distanceFilter: 20 }
		);
	}

	getContainerHeight = (height) => {
		this.setState({
			containerHeight : height
		});
	}

	setPanelContent = (text) => {
		NearbyService.FetchSearchResults(text).then((result) => {
			if (result.results) {
				this.setState({
					searchResults: result.results,
					selectedResult: result.results[0]
				});
			} else {
				// handle no results
			}
		});
	}

	updateSelectedResult = (index) => {
		const newSelect = this.state.searchResults[index];
		this.setState({
			selectedResult: newSelect
		});
		this.panel.collapsePanel();
	}

	render() {
		if (this.state.initialRegion) {
			return (
				<View style={[css.main_container, css.whitebg]}>
					<SearchBar
						placeholder={'Search'}
						update={this.setPanelContent}
					/>
					<MapView
						ref={(MapRef) => {
							if ( MapRef != null && this.state.searchResults ) {
								let markers = [];
								markers.push({ latitude: this.state.initialRegion.latitude, longitude: this.state.initialRegion.longitude });
								markers.push({ latitude: this.state.selectedResult.mkrLat, longitude: this.state.selectedResult.mkrLong });

								MapRef.fitToCoordinates(
									markers,
									{
										edgePadding: { top: 100, right: 100, bottom: 1000, left: 100 },
										animated: true,
									}
								);
							}
						}}
						style={css.nearby_map_container}
						loadingEnabled={true}
						loadingIndicatorColor={'#666'}
						loadingBackgroundColor={'#EEE'}
						showsUserLocation={true}
						mapType={'standard'}
						followsUserLocation={true}
						initialRegion={this.state.initialRegion}
						onCalloutPress={
							() => gotoNavigationApp(this.state.selectedResult.mkrLat, this.state.selectedResult.mkrLong)
						}
					>
						{(this.state.searchResults && !this.state.sliding) ? (
							<MapView.Marker
								coordinate={{
									latitude: this.state.selectedResult.mkrLat,
									longitude: this.state.selectedResult.mkrLong
								}}
								title={this.state.selectedResult.title}
								description={this.state.selectedResult.description}
								identifier={this.state.selectedResult.title}
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
					<SlidingUpPanel
						ref={panel => { this.panel = panel; }}
						containerMaximumHeight={MAXIMUM_HEIGHT}
						containerBackgroundColor={'white'}
						handlerHeight={MINUMUM_HEIGHT}
						allowStayMiddle={true}
						handlerDefaultView={<HandlerOne />}
						getContainerHeight={this.getContainerHeight}
						onStart={() => this.setState({ sliding: true })}
						onEnd={() => this.setState({ sliding: false })}
					>
						{(this.state.searchResults) ? (
							<View>
								<ResultsList results={this.state.searchResults} onSelect={(index) => this.updateSelectedResult(index)} />
							</View>
							) : (null)}
					</SlidingUpPanel>
				</View>
			);
		} else {
			return null;
		}
	}
}

const HandlerOne = ({ props }) => (
	<View>
		<Text >Search Results</Text>
	</View>
);

const ResultsList = ({ results, onSelect }) => (
	<View>
		{results.map((result, index) => (
			<TouchableHighlight key={index} underlayColor={'rgba(200,200,200,.1)'} onPress={() => onSelect(index)}>
				<View style={css.destinationcard_marker_row}>
					<Icon name="map-marker" size={30} />
					<Text style={css.destinationcard_marker_label}>{result.title}</Text>
				</View>
			</TouchableHighlight>
		))}
	</View>
);

const gotoNavigationApp = (destinationLat, destinationLon) => {
	const destinationURL = general.getDirectionsURL('walk', destinationLat, destinationLon );
	general.openURL(destinationURL);
};
