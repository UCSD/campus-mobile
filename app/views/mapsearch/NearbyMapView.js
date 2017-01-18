import React from 'react';
import {
	View,
	Dimensions,
	ScrollView,
	Text,
	StyleSheet,
	TouchableOpacity,
	Switch
} from 'react-native';
import { connect } from 'react-redux';
import ElevatedView from 'react-native-elevated-view';
import SideMenu from 'react-native-side-menu';
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

const shuttle_stops = require('../../json/shuttle_stops_master_map.json');
const shuttle_routes = require('../../json/shuttle_routes_master_map.json');

class NearbyMapView extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			searchInput: null,
			searchResults: null,
			selectedResult: null,
			sliding: false,
			typing: false,
			allowScroll: true,
			iconStatus: 'menu',
			showBar: true,
			showMenu: false,
		};
	}

	componentWillMount() {
		Object.keys(shuttle_routes).map((key, index) => {
			this.setState({ ['route' + key] : true });
			return null;
		});
	}

	shouldComponentUpdate(nextProps, nextState) {
		// return true;
		// Don't re-render if location hasn't changed
		if (((this.props.location.coords.latitude !== nextProps.location.coords.latitude) ||
			(this.props.location.coords.longitude !== nextProps.location.coords.longitude)) ||
			this.state !== nextState) {
			/*
			(this.state.selectedResult !== nextState.selectedResult) ||
			(this.state.iconStatus !== nextState.iconStatus) ||
			(this.state.showBar !== nextState.showBar) ||
			(this.state.showMenu !== nextState.showMenu) ||
			(this.state.route1 !== nextState.route1)) {*/

			return true;
		} else {
			return false;
		}
	}

	pressIcon = () => {
		if (this.state.iconStatus === 'back') {
			this.setState({
				iconStatus: 'menu',
				showBar: true
			});
			this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
			// this.barRef.clear();
			this.barRef.blur();
		} else if (this.state.iconStatus === 'menu') {
			this.updateMenuState(true);
		}
	}

	pressHistory = (text) => {
		this.pressIcon();
		this.updateSearch(text);
	}

	gotoResults = () => {
		this.setState({
			iconStatus: 'back',
			showBar: false
		});
		this.scrollRef.scrollTo({ x: 0, y: deviceHeight - Math.round(44 * getPRM()) + 6, animated: true });
	}

	focusSearch = () => {
		this.scrollRef.scrollTo({ x: 0, y: (2 * deviceHeight) - Math.round(2 * 44 * getPRM()) - 12, animated: true });
		this.setState({
			iconStatus: 'back',
			showBar: false
		});
	}

	updateSearch = (text) => {
		NearbyService.FetchSearchResults(text).then((result) => {
			if (result.results) {
				this.setState({
					searchInput: text,
					searchResults: result.results,
					selectedResult: result.results[0],
					showBar: true
				});
				this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
			} else {
				// handle no results
			}
		});
	}

	updateSelectedResult = (index) => {
		const newSelect = this.state.searchResults[index];
		this.setState({
			iconStatus: 'menu',
			selectedResult: newSelect,
			showBar: true
		});
		this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
	}

	updateMenuState = (showMenu) => {
		this.setState({ showMenu, });
	}

	toggleRoute = (value, key) => {
		if (value === false) {
			// Remove route from every stop
			Object.keys(shuttle_routes[key].stops).map((key2, index2) => {
				if (shuttle_stops[key2])
					delete shuttle_stops[key2].routes[key];
				return null;
			});
		} else {
			// Add route to every stop
			Object.keys(shuttle_routes[key].stops).map((key2, index2) => {
				if (shuttle_stops[key2])
					shuttle_stops[key2].routes[key] = shuttle_routes[key];
				return null;
			});
		}
		this.setState({ ['route' + key] : value });
	}

	render() {
		const menu = (
			<ScrollView scrollsToTop={false} style={styles.menu}>
				<View>
					{
						// Create switch for every shuttle route
						Object.keys(shuttle_routes).map((key, index) => (
							<View>
								<Text>{shuttle_routes[key].name.trim()}</Text>
								<Switch
									onValueChange={(val) => this.toggleRoute(val, key)}
									value={this.state['route' + key]}
								/>
							</View>
							)
						)
					}
				</View>
			</ScrollView>
		);

		if (this.props.location.coords) {
			return (
				<SideMenu
					menu={menu}
					isOpen={this.state.showMenu}
					onChange={(isOpen) => this.updateMenuState(isOpen)}
				>
					<View style={css.main_container}>
						<View
							// Only necessary for ios?
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
								shuttle={shuttle_stops}
							/>
							<View
								style={styles.bottomContainer}
							>
								<View
									style={styles.spacer}
								/>
								<SearchResults
									results={this.state.searchResults}
									onSelect={(index) => this.updateSelectedResult(index)}
								/>
								<View
									style={styles.spacer}
								/>
								<SearchHistoryCard
									pressHistory={this.pressHistory}
								/>
								<View
									style={styles.spacer}
								/>
							</View>
						</ScrollView>
						{(this.state.showBar) ? (
							<ElevatedView
								style={styles.bottomBarContainer}
								elevation={5}
							>
								<TouchableOpacity
									onPress={
										this.gotoResults
									}
								>
									<Text
										style={styles.bottomBarText}
									>
										See More Results
									</Text>
								</TouchableOpacity>
							</ElevatedView>
							) : (null)
						}
					</View>
				</SideMenu>
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
	bottomBarContainer: { zIndex: 1, flex: 1, alignItems: 'center', justifyContent: 'center', position: 'absolute', bottom: Math.round(44 * getPRM()) + 24, width: deviceWidth, height: Math.round(44 * getPRM()), borderWidth: 0, backgroundColor: 'white', },
	bottomBarContent: { flex:1, alignItems:'center', justifyContent:'center' },
	bottomBarText: { textAlign: 'center', },

	bottomContainer: { minHeight: deviceHeight },
	map_container : { flex: 1, width: deviceWidth, height: deviceHeight - Math.round(44 * getPRM()), },
	spacer: { height: Math.round(44 * getPRM()) + 12 },
});
