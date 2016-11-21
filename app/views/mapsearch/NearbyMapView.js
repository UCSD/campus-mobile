import React from 'react';
import {
	View,
	Dimensions,
	TouchableHighlight,
	Text
} from 'react-native';
import { connect } from 'react-redux';

import SlidingUpPanel from 'react-native-sliding-up-panel';
import Icon from 'react-native-vector-icons/FontAwesome';
import SearchBar from './SearchBar';
import SearchMap from './SearchMap';
import SearchResults from './SearchResults';
import NearbyService from '../../services/nearbyService';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const shuttle = require('../../util/shuttle');
const AppSettings = 		require('../../AppSettings');
const general = require('../../util/general');

let navBarMarginTop = 64;
let searchMargin = navBarMarginTop;

if (general.platformAndroid()) {
	navBarMarginTop = 64;
	searchMargin = 0;
}

const deviceHeight = Dimensions.get('window').height;

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
					<View
						style={{
							marginTop:searchMargin,
						}}
					>
						<SearchBar
							update={this.updateSearch}
						/>
					</View>
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

function mapStateToProps(state, props) {
	return {
		location: state.location.position,
		locationPermission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(NearbyMapView);
