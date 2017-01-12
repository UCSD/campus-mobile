import React from 'react';
import {
	View,
	Dimensions,
	ScrollView,
	Text,
	StyleSheet,
} from 'react-native';
import { connect } from 'react-redux';

import Icon from 'react-native-vector-icons/FontAwesome';
import SearchBar from './SearchBar';
import SearchMap from './SearchMap';
import SearchResults from './SearchResults';
import SearchHistoryCard from './SearchHistoryCard';
import NearbyService from '../../services/nearbyService';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const shuttle = require('../../util/shuttle');
const AppSettings = 		require('../../AppSettings');

import general, { getPRM } from '../../util/general';

let navBarMarginTop = 64;
let searchMargin = navBarMarginTop;

if (general.platformAndroid()) {
	navBarMarginTop = 64;
	searchMargin = 0;
}

const deviceHeight = Dimensions.get('window').height;
const deviceWidth = Dimensions.get('window').width;

const MAXIMUM_HEIGHT = deviceHeight - navBarMarginTop;
const MINUMUM_HEIGHT = navBarMarginTop;

class NearbyMapView extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			searchInput: null,
			searchResults: null,
			selectedResult: null,
			sliding: false,
			typing: false,
			allowScroll: false,
			iconStatus: 'menu'
		};
	}

	componentWillMount() {

	}

	shouldComponentUpdate(nextProps, nextState) {
		// return true;
		// Don't re-render if location hasn't changed
		if (((this.props.location.coords.latitude !== nextProps.location.coords.latitude) &&
			(this.props.location.coords.longitude !== nextProps.location.coords.longitude)) ||
			(this.state.selectedResult !== nextState.selectedResult) ||
			(this.state.iconStatus !== nextState.iconStatus)) {
			return true;
		} else {
			return false;
		}
	}

	pressIcon = () => {
		if (this.state.iconStatus === 'back') {
			this.setState({
				iconStatus: 'menu'
			});
			this.scrollRef.scrollTo(0);
			// this.barRef.clear();
			this.barRef.blur();
		}
	}

	pressHistory = (text) => {
		this.pressIcon();
		this.updateSearch(text);
	}

	focusSearch = () => {
		this.setState({
			iconStatus: 'back'
		});
		this.scrollRef.scrollTo(deviceHeight);
	}

	updateSearch = (text) => {
		NearbyService.FetchSearchResults(text).then((result) => {
			if (result.results) {
				this.setState({
					searchInput: text,
					searchResults: result.results,
					selectedResult: result.results[0]
				});
				this.scrollRef.scrollTo(0);
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
		this.scrollRef.scrollTo(0);
	}

	render() {
		if (this.props.location.coords) {
			return (
				<View style={css.main_container}>
					<View
						style={{
							zIndex: 1
						}}
					>
						<SearchBar
							update={this.updateSearch}
							onFocus={this.focusSearch}
							pressIcon={this.pressIcon}
							iconStatus={this.state.iconStatus}
							searchInput={this.state.searchInput}
							reff={
								(ref) => { this.barRef = ref; }
							}
						/>
					</View>
					<ScrollView
						ref={
							(ref) => {
								this.scrollRef = ref;
							}
						}
						showsVerticalScrollIndicator={false}
						scrollEnabled={this.state.allowScroll}
					>
						<SearchMap
							location={this.props.location}
							selectedResult={this.state.selectedResult}
							style={styles.map_container}
							hideMarker={this.state.sliding}
						/>
						<View
							style={styles.bottomContainer}
						>
							<View
								style={styles.spacer}
							/>
							{(this.state.searchResults) ? (
								<View>
									<SearchResults
										results={this.state.searchResults}
										onSelect={(index) => this.updateSelectedResult(index)}
									/>
								</View>
								) : (null)}
							<SearchHistoryCard
								pressHistory={this.pressHistory}
							/>
						</View>
					</ScrollView>
				</View>
			);
		} else {
			return null;
		}
	}
}

function mapStateToProps(state, props) {
	return {
		location: state.location.position,
		locationPermission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(NearbyMapView);

const styles = StyleSheet.create({
	bottomContainer: { minHeight: deviceHeight },
	map_container : { flex: 1, width: deviceWidth, height: deviceHeight },
	spacer: { height: Math.round(44 * getPRM()) + 10 },
});
