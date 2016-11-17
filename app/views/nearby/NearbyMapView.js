import React from 'react';
import {
	View,
	ListView,
	Dimensions,
	TouchableHighlight,
	Text
} from 'react-native';
import { connect } from 'react-redux';

import SlidingUpPanel from 'react-native-sliding-up-panel';
import SearchBar from './SearchBar';
import SearchMap from './SearchMap';
import SearchResults from './SearchResults';
import NearbyService from '../../services/nearbyService';
import Icon from 'react-native-vector-icons/FontAwesome';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const shuttle = require('../../util/shuttle');
const AppSettings = 		require('../../AppSettings');
const general = require('../../util/general');
const MapView = require('react-native-maps');

const navBarMarginTop = 0;

if (general.platformAndroid()) {
	navBarMarginTop = 64;
}

const deviceHeight = Dimensions.get('window').height;
const deviceWidth = Dimensions.get('window').width;

const MAXIMUM_HEIGHT = deviceHeight - navBarMarginTop;
const MINUMUM_HEIGHT = navBarMarginTop;

class NearbyMapView extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			initialRegion: {
				latitude: this.props.location.coords.latitude,
				longitude: this.props.location.coords.longitude,
				latitudeDelta: 0.02,
				longitudeDelta: 0.02
			},
			searchResults: null,
			selectedResult: null,
			sliding: false,
		};
	}

	componentWillMount() {

	}

	getContainerHeight = (height) => {
		this.setState({
			containerHeight : height
		});
	}

	updateSearch = (text) => {
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
		console.log('render map');
		if (this.state.initialRegion) {
			return (
				<View style={css.view_all_container}>
					<SearchBar
						update={this.updateSearch}
						style={{ marginTop:25, marginBottom:25 }}
					/>
					<SearchMap
						location={this.props.location}
						selectedResult={this.state.selectedResult}
						style={css.search_map_container}
						hideMarker={this.state.sliding}
					/>
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
								<SearchResults
									results={this.state.searchResults}
									onSelect={(index) => this.updateSelectedResult(index)}
								/>
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
		<View style={{ flexDirection: 'row', alignItems: 'center' }}>
			<TouchableHighlight 
				underlayColor={'rgba(200,200,200,.1)'} 
				onPress={() => onSelect(index)}
				style={{ flex: 1, alignItems: 'center' }}
			>
				<Icon name="long-arrow-left" size={30} />
			</TouchableHighlight>
			<TouchableHighlight 
				underlayColor={'rgba(200,200,200,.1)'} 
				onPress={() => onSelect(index)}
				style={{ flex: 1, alignItems: 'center' }}
			>
				<Icon name="long-arrow-right" size={30} />
			</TouchableHighlight>
		</View>
	</View>
);

const gotoNavigationApp = (destinationLat, destinationLon) => {
	const destinationURL = general.getDirectionsURL('walk', destinationLat, destinationLon );
	general.openURL(destinationURL);
};

function mapStateToProps(state, props) {
	return {
		location: state.location.position,
		locationPermission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(NearbyMapView);
