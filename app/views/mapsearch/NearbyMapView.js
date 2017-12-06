import React from 'react';
import {
	View,
	Dimensions,
	ScrollView,
	Text,
	StyleSheet,
	TouchableOpacity,
	Platform,
	StatusBar,
	BackAndroid
} from 'react-native';
import { connect } from 'react-redux';
import MapView from 'react-native-maps';
import { checkGooglePlayServices, openGooglePlayUpdate } from 'react-native-google-api-availability-bridge';
import { COLOR_MGREY } from '../../styles/ColorConstants';
import SearchResultsBar from './SearchResultsBar';
import SearchNavButton from './SearchNavButton';
import SearchShuttleButton from './SearchShuttleButton';
import SearchBar from './SearchBar';
import SearchMap from './SearchMap';
import SearchResults from './SearchResults';
import SearchHistoryCard from './SearchHistoryCard';
import SearchSuggest from './SearchSuggest';
import SearchShuttleMenu from './SearchShuttleMenu';
import Toast from 'react-native-simple-toast';

import css from '../../styles/css';
import logger from '../../util/logger';

import { gotoNavigationApp, platformAndroid } from '../../util/general';

const deviceHeight = Dimensions.get('window').height;
const deviceWidth = Dimensions.get('window').width;
const statusBarHeight = Platform.select({
	ios: 0,
	android: StatusBar.currentHeight,
});

class NearbyMapView extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			searchInput: null,
			selectedResult: 0,
			typing: false,
			allowScroll: false,
			iconStatus: 'search',
			showBar: false,
			showShuttle: true,
			showNav: false,
			showMenu: false,
			vehicles: {},
			updatedGoogle: true,
		};
	}

	componentWillMount() {
		if (platformAndroid()) {
			checkGooglePlayServices((result) => {
				if (result === 'update') {
					this.setState({ updatedGoogle: false });
				}
			});
		}
	}

	componentDidMount() {
		logger.ga('View mounted: Full Map View');

		BackAndroid.addEventListener('hardwareBackPress', this.pressIcon);
	}

	componentWillReceiveProps(nextProps) {
		// Clear search results when navigating away
		if (nextProps.scene.key !== this.props.scene.key) {
			this.props.clearSearch();
			this.setState({ searchInput: null });
		}

		// Loop thru every vehicle
		Object.keys(nextProps.toggles).forEach((route) => {
			if (nextProps.toggles[route] === true && Array.isArray(nextProps.vehicles[route])) {
				if (this.state.vehicles[route]) {
					nextProps.vehicles[route].forEach((nextVehicle) => {
						this.state.vehicles[route].forEach((currVehicle) => {
							if (nextVehicle.id === currVehicle.id &&
								(nextVehicle.lat !== currVehicle.lat || nextVehicle.lon !== currVehicle.lon)) {
								// Animate vehicle movement
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
					nextProps.vehicles[route].forEach((nextVehicle) => {
						nextVehicle.animated = new MapView.AnimatedRegion({
							latitude: nextVehicle.lat,
							longitude: nextVehicle.lon,
						});
					});

					const newVehicles = this.state.vehicles;
					newVehicles[route] = nextProps.vehicles[route];

					this.setState({
						vehicles: newVehicles
					});
				}
			}
		});

		if (this.state.iconStatus === 'load' && nextProps.search_results) {
			this.setState({
				iconStatus: 'search'
			});
		}
	}

	shouldComponentUpdate(nextProps, nextState) {
		// Don't re-render if location hasn't changed
		if (((this.props.location.coords.latitude !== nextProps.location.coords.latitude) ||
			(this.props.location.coords.longitude !== nextProps.location.coords.longitude)) ||
			this.state !== nextState ||
			this.props.search_results !== nextProps.search_results ||
			this.props.search_history.length !== nextProps.search_history.length) {
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

	componentWillUnmount() {
		BackAndroid.removeEventListener('hardwareBackPress', this.pressIcon);
		clearTimeout(this.timer);
		this.props.clearSearch();
	}

	// Returns true so router-flux back handler is ignored
	pressIcon = () => {
		if (this.state.iconStatus === 'back') {
			this.setState({
				iconStatus: 'search',
				showBar: (this.props.search_results !== null),
				showShuttle: true,
				showNav: true,
			});
			this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
			// this.barRef.clear();
			this.barRef.blur();
			return true;
		} else {
			return false;
		}
	}

	gotoResults = () => {
		this.setState({
			iconStatus: 'back',
			showBar: false,
			showShuttle: false,
			showNav: false
		});
		this.scrollRef.scrollTo({ x: 0, y: deviceHeight - 64 - statusBarHeight, animated: true });
	}

	focusSearch = () => {
		this.scrollRef.scrollTo({ x: 0, y: 2 * (deviceHeight - 64 - statusBarHeight), animated: true });
		this.setState({
			iconStatus: 'back',
			showBar: false,
			showShuttle: false,
			showNav: false,
		});
	}

	gotoShuttleSettings = () => {
		this.setState({
			iconStatus: 'back',
			showBar: false,
			showShuttle: false,
			showNav: false,
		});
		this.scrollRef.scrollTo({ x: 0, y: 3 * (deviceHeight - 64 - statusBarHeight), animated: true });
	}

	gotoNavigationApp = () => {
		if (this.props.search_results && this.state.showNav) {
			gotoNavigationApp(this.props.search_results[this.state.selectedResult].mkrLat, this.props.search_results[this.state.selectedResult].mkrLong);
		} else {
			// Do nothing, this shouldn't be reached
		}
	}

	updateSearch = (text) => {
		if (text && text.trim() !== '') {
			this.props.fetchSearch(text);
			this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
			this.barRef.blur();

			this.setState({
				searchInput: text,
				showBar: true,
				iconStatus: 'load',
				showShuttle: true,
				showNav: true,
				selectedResult: 0
			});

			this.timer = setTimeout(this.searchTimeout, 5000);
		}
	}

	searchTimeout = () => {
		if (!this.props.search_results) {
			Toast.showWithGravity('No results found for your search.', Toast.SHORT, Toast.BOTTOM);
			this.setState({
				iconStatus: 'search'
			});
		}
	}

	updateSearchSuggest = (text) => {
		this.props.fetchSearch(text, this.props.location);
		this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
		this.barRef.blur();

		this.setState({
			searchInput: text,
			showBar: true,
			iconStatus: 'load',
			showShuttle: true,
			showNav: true,
			selectedResult: 0
		});
	}

	updateSelectedResult = (index) => {
		const newSelect = index;
		this.setState({
			iconStatus: 'search',
			selectedResult: newSelect,
			showBar: true,
			showShuttle: true,
			showNav: true,
		});
		this.scrollRef.scrollTo({ x: 0, y: 0, animated: true });
	}

	toggleRoute = (route) => {
		this.pressIcon();
		this.props.toggle(route);
		// const vehicles = this.state.vehicles;
		// delete vehicles[route];

		this.setState({	vehicles: {} });
	}

	render() {
		if (platformAndroid() && !this.state.updatedGoogle) {
			return (
				<View style={css.main_container}>
					<Text>Please update Google Play Services and restart app to view map.</Text>
					<TouchableOpacity underlayColor={'rgba(200,200,200,.1)'} onPress={() => openGooglePlayUpdate()}>
						<View style={css.eventdetail_readmore_container}>
							<Text style={css.eventdetail_readmore_text}>Update</Text>
						</View>
					</TouchableOpacity>
				</View>
			);
		}
		if (this.props.location.coords) {
			return (
				<View style={css.main_container}>
					<SearchNavButton
						visible={(this.state.showNav && this.props.search_results !== null)}
						onPress={this.gotoNavigationApp}
					/>
					<SearchShuttleButton
						visible={this.state.showShuttle}
						onPress={this.gotoShuttleSettings}
					/>
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
						keyboardShouldPersistTaps='always'
					>
						<View
							style={styles.section}
						>
							<SearchMap
								location={this.props.location}
								selectedResult={
									(this.props.search_results) ? (
										this.props.search_results[this.state.selectedResult]
									) : null
								}
								shuttle={this.props.shuttle_stops}
								vehicles={this.state.vehicles}
							/>
						</View>
						<View
							style={styles.section}
						>
							<SearchResults
								results={this.props.search_results}
								onSelect={(index) => this.updateSelectedResult(index)}
							/>
						</View>
						<View
							style={styles.section}
						>
							<SearchSuggest
								onPress={this.updateSearchSuggest}
							/>
							{(Array.isArray(this.props.search_history) && (this.props.search_history.length !== 0)) ? (
								<SearchHistoryCard
									pressHistory={this.updateSearch}
									removeHistory={this.props.removeHistory}
									data={this.props.search_history}
								/>
								) : (null)}
						</View>
						<View
							style={styles.section}
						>
							<SearchShuttleMenu
								shuttle_routes={this.props.shuttle_routes}
								onToggle={this.toggleRoute}
								toggles={this.props.toggles}
							/>
						</View>
					</ScrollView>
					<SearchResultsBar
						visible={(this.state.showBar && this.props.search_results !== null)}
						onPress={this.gotoResults}
					/>
				</View>
			);
		} else {
			return null;
		}
	}
}

const mapStateToProps = (state, props) => (
	{
		location: state.location.position,
		locationPermission: state.location.permission,
		toggles: state.shuttle.toggles,
		shuttle_routes: state.shuttle.routes,
		shuttle_stops: state.shuttle.stops,
		vehicles: state.shuttle.vehicles,
		search_history: state.map.history,
		search_results: state.map.results,
		scene: state.routes.scene
	}
);

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		clearSearch: () => {
			dispatch({ type: 'CLEAR_MAP_SEARCH' });
		},
		fetchSearch: (term, location) => {
			dispatch({ type: 'FETCH_MAP_SEARCH', term, location });
		},
		toggle: (route) => {
			dispatch({ type: 'UPDATE_TOGGLE_ROUTE', route });
		},
		removeHistory: (index) => {
			dispatch({ type: 'REMOVE_HISTORY', index });
		}
	}
);

module.exports = connect(mapStateToProps, mapDispatchToProps)(NearbyMapView);

const navMargin = Platform.select({
	ios: 64,
	android: 0
});

const styles = StyleSheet.create({
	main_container: { width: deviceWidth, height: deviceHeight - 64 - statusBarHeight, backgroundColor: COLOR_MGREY, marginTop: navMargin },
	section: { height: deviceHeight - 64 - statusBarHeight },
});

