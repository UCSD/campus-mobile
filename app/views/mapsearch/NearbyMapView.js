import React from 'react';
import {
	View,
	Dimensions,
	ScrollView,
	Text,
	StyleSheet,
	TouchableOpacity,
	Platform,
	StatusBar
} from 'react-native';
import { connect } from 'react-redux';
import ElevatedView from 'react-native-elevated-view';
import SideMenu from 'react-native-side-menu';
import Icon from 'react-native-vector-icons/FontAwesome';
import MapView from 'react-native-maps';

import SearchSideMenu from './SearchSideMenu';
import SearchBar from './SearchBar';
import SearchMap from './SearchMap';
import SearchResults from './SearchResults';
import SearchHistoryCard from './SearchHistoryCard';
import NearbyService from '../../services/nearbyService';
import ShuttleLocationContainer from '../../containers/shuttleLocationContainer';

import { toggleRoute } from '../../actions/shuttle';
import { saveSearch } from '../../actions/map';

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
const statusBarHeight = Platform.select({
	ios: 0,
	android: StatusBar.currentHeight,
});

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
			allowScroll: false,
			iconStatus: 'menu',
			showBar: false,
			showMenu: false,
			toggled: false,
			vehicles: {}
		};
	}

	componentWillMount() {
		Object.keys(shuttle_routes).forEach((key, index) => {
			this.setState({ ['route' + key] : false });
		});
	}

	componentWillReceiveProps(nextProps) {
		// Loop thru every vehicle
		Object.keys(nextProps.vehicles).forEach((key, index) => {
			if (this.state.vehicles[key]) {
				nextProps.vehicles[key].forEach((nextVehicle) => {
					this.state.vehicles[key].forEach((currVehicle) => {
						if (nextVehicle.id === currVehicle.id &&
							(nextVehicle.lat !== currVehicle.lat || nextVehicle.lon !== currVehicle.lon)) {
							currVehicle.animated.timing({
								latitude: nextVehicle.lat,
								longitude: nextVehicle.lon,
								duration: 500
							}).start();
						}
					});
				});
			} else {
				// Make Animated values
				nextProps.vehicles[key].forEach((nextVehicle) => {
					nextVehicle.animated = new MapView.AnimatedRegion({
						latitude: nextVehicle.lat,
						longitude: nextVehicle.lon,
					});
				});

				const newVehicles = this.state.vehicles;
				newVehicles[key] = nextProps.vehicles[key];

				this.setState({
					vehicles: newVehicles
				});
			}
		});
	}

	shouldComponentUpdate(nextProps, nextState) {
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
				showBar: (this.state.searchResults !== null)
			});
			this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
			// this.barRef.clear();
			this.barRef.blur();
		} else if (this.state.iconStatus === 'menu') {
			this.updateMenuState(true);
		}
	}

	gotoResults = () => {
		this.setState({
			iconStatus: 'back',
			showBar: false
		});
		this.scrollRef.scrollTo({ x: 0, y: deviceHeight - 64 - statusBarHeight, animated: true });
	}

	focusSearch = () => {
		this.scrollRef.scrollTo({ x: 0, y: 2 * (deviceHeight - 64 - statusBarHeight), animated: true });
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
					showBar: true,
					iconStatus: 'menu',
				});
				this.props.dispatch(saveSearch(text));  // Save search term
				this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
				this.barRef.blur();
			} else {
				this.setState({
					searchInput: 'No Results, please try a different term',
					searchResults: null,
					selectedResult: null,
					showBar: false,
					iconStatus: 'menu',
				});
				this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
				this.barRef.blur();
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

	toggleRoute = (value, route) => {
		this.props.dispatch(toggleRoute(route));

		const vehicles = this.state.vehicles;
		delete vehicles[route];

		this.setState({
			toggled: !this.state.toggled,
			vehicles });
	}

	render() {
		console.log("ivan: " + deviceHeight + " prm: " + (44*getPRM()));
		if (this.props.location.coords) {
			return (
				<SideMenu
					menu={
						<SearchSideMenu
							shuttle_routes={shuttle_routes}
							onToggle={this.toggleRoute}
							toggles={this.props.toggles}
						/>
					}
					edgeHitWidth={0} //Disable open sidemenu from swipe
					isOpen={this.state.showMenu}
					onChange={(isOpen) => this.updateMenuState(isOpen)}
				>
					<View style={css.main_container}>
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
						<ScrollView
							ref={
								(ref) => {
									this.scrollRef = ref;
								}
							}
							showsVerticalScrollIndicator={false}
							scrollEnabled={this.state.allowScroll}
						>
							<View
								style={styles.section}
							>
								<SearchMap
									location={this.props.location}
									selectedResult={this.state.selectedResult}
									hideMarker={this.state.sliding}
									shuttle={this.props.shuttle_stops}
									vehicles={this.state.vehicles}
								/>
							</View>
							<View
								style={styles.section}
							>
								<SearchResults
									results={this.state.searchResults}
									onSelect={(index) => this.updateSelectedResult(index)}
								/>
							</View>
							<View
								style={styles.section}
							>
								{(this.props.search_history.length !== 0) ? (
									<SearchHistoryCard
										pressHistory={this.updateSearch}
										data={this.props.search_history}
									/>
									) : (null)}
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
					<ShuttleLocationContainer />
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
		locationPermission: state.location.permission,
		toggles: state.shuttle.toggles,
		shuttle_routes: state.shuttle.routes,
		shuttle_stops: state.shuttle.stops,
		vehicles: state.shuttle.vehicles,
		search_history: state.map.history,
	};
}

module.exports = connect(mapStateToProps)(NearbyMapView);

const navMargin = Platform.select({
	ios: 64,
	android: 0
});

const styles = StyleSheet.create({
	main_container: { width: deviceWidth, height: deviceHeight - 64 - statusBarHeight, backgroundColor: '#EAEAEA', marginTop: navMargin },
	bottomBarContainer: { zIndex: 5, alignItems: 'center', justifyContent: 'center', position: 'absolute', bottom: 0, width: deviceWidth, height: Math.round(44 * getPRM()), borderWidth: 0, backgroundColor: 'white', },
	bottomBarContent: { flex:1, alignItems:'center', justifyContent:'center' },
	bottomBarText: { textAlign: 'center', },

	section: { height: deviceHeight - 64 - statusBarHeight },
});

