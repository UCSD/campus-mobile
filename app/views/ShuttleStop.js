'use strict';

import React from 'react';
import {
	View,
	Text,
	Navigator,
	TouchableHighlight,
	ScrollView,
	Image,
	Animated,
	Easing,
	RefreshControl,
	InteractionManager,
	ActivityIndicator
} from 'react-native';
var MapView = require('react-native-maps');

var TimerMixin = 		require('react-timer-mixin');
var AppSettings = 		require('../AppSettings');
var allShuttleRoutes = 	require('../json/shuttle_routes_master.json');
var css = 				require('../styles/css');

var general = 			require('../util/general');
var logger = 			require('../util/logger');
var shuttle = 			require('../util/shuttle');

var responseDataRef = [];
var responseDataSort = [];
var responseDataSortRef = [];

import NavigationBarWithRouteMapper from './NavigationBarWithRouteMapper';

var ShuttleStop = React.createClass({

	mixins: [TimerMixin],
	shuttleRefreshInterval: 30 * 1000,				// 30 seconds between shuttle api updates
	shuttleReloadAnim: new Animated.Value(0),
	shuttleMainReloadAnim: new Animated.Value(0),
	shuttleRefreshTimestamp: null,
	map_legal_disclaimer: { bottom: 5, right: 5 },
	delayMapViewLoad: 250,

	getInitialState: function() {
		return {
			loaded: false,
			isRefreshing: false,
			shuttleRefreshTimeAgo: ' ',
			closestShuttlesLoaded: false,
			closestShuttlesInactive: false,

			shuttleStopID: this.props.route.stopData.stopID,
			shuttleStopName: this.props.route.stopData.stopName,
			shuttleStopLat: this.props.route.stopData.stopLat,
			shuttleStopLon: this.props.route.stopData.stopLon,

			region: {
				latitude: this.props.route.stopData.stopLat,
				longitude: this.props.route.stopData.stopLon,
			},

			shuttleStopMarker: [{
				latitude: this.props.route.stopData.stopLat,
				longitude: this.props.route.stopData.stopLon,
				title: this.props.route.stopData.stopName,
			}],

			mapDeltaViewLoader: false,
			mapViewLoadReady: false,
			mapDelta: .01,

			currentPosition: this.props.route.currentPosition,
			defaultPosition: {
				coords: { latitude: '32.88', longitude: '-117.234' }
			},

			shuttleStopImageDict: {
				'141014': require('../assets/img/shuttle/shuttle-stop-141014.jpg'),
				'141030': require('../assets/img/shuttle/shuttle-stop-141030.jpg'),
				'141042': require('../assets/img/shuttle/shuttle-stop-141042.jpg'),
				'141056': require('../assets/img/shuttle/shuttle-stop-141056.jpg'),
				'141062': require('../assets/img/shuttle/shuttle-stop-141062.jpg'),
				'141080': require('../assets/img/shuttle/shuttle-stop-141080.jpg'),
				'141111': require('../assets/img/shuttle/shuttle-stop-141111.jpg'),
				'141138': require('../assets/img/shuttle/shuttle-stop-141138.jpg'),
				'1542847': require('../assets/img/shuttle/shuttle-stop-1542847.jpg'),
				'1614005': require('../assets/img/shuttle/shuttle-stop-1614005.jpg'),
				'239930': require('../assets/img/shuttle/shuttle-stop-239930.jpg'),
				'239948': require('../assets/img/shuttle/shuttle-stop-239948.jpg'),
				'240096': require('../assets/img/shuttle/shuttle-stop-240096.jpg'),
				'28109': require('../assets/img/shuttle/shuttle-stop-28109.jpg'),
				'28122': require('../assets/img/shuttle/shuttle-stop-28122.jpg'),
				'30732': require('../assets/img/shuttle/shuttle-stop-30732.jpg'),
				'32417': require('../assets/img/shuttle/shuttle-stop-32417.jpg'),
				'34893': require('../assets/img/shuttle/shuttle-stop-34893.jpg'),
				'377671': require('../assets/img/shuttle/shuttle-stop-377671.jpg'),
				'382806': require('../assets/img/shuttle/shuttle-stop-382806.jpg'),
				'382807': require('../assets/img/shuttle/shuttle-stop-382807.jpg'),
				'382908': require('../assets/img/shuttle/shuttle-stop-382908.jpg'),
				'382909': require('../assets/img/shuttle/shuttle-stop-382909.jpg'),
				'382910': require('../assets/img/shuttle/shuttle-stop-382910.jpg'),
				'382911': require('../assets/img/shuttle/shuttle-stop-382911.jpg'),
				'382912': require('../assets/img/shuttle/shuttle-stop-382912.jpg'),
				'382913': require('../assets/img/shuttle/shuttle-stop-382913.jpg'),
				'385742': require('../assets/img/shuttle/shuttle-stop-385742.jpg'),
				'385744': require('../assets/img/shuttle/shuttle-stop-385744.jpg'),
				'493852': require('../assets/img/shuttle/shuttle-stop-493852.jpg'),
				'493872': require('../assets/img/shuttle/shuttle-stop-493872.jpg'),
				'757589': require('../assets/img/shuttle/shuttle-stop-757589.jpg'),
				'757600': require('../assets/img/shuttle/shuttle-stop-757600.jpg'),
				'9158': require('../assets/img/shuttle/shuttle-stop-9158.jpg'),
				'93814': require('../assets/img/shuttle/shuttle-stop-93814.jpg'),
				'93904': require('../assets/img/shuttle/shuttle-stop-93904.jpg'),
				'93943': require('../assets/img/shuttle/shuttle-stop-93943.jpg'),
				'9920': require('../assets/img/shuttle/shuttle-stop-9920.jpg'),
			},
		}
	},

	componentWillMount: function() {
		//this.fetchShuttleArrivalsByStop('auto');
		// Initial shuttle info render passed from home
		//this._processShuttleArrivals(this.props.route.shuttleData);
		//this.mapViewTimeout = this.setTimeout( () => { this.loadMapView() }, this.delayMapViewLoad);
	},

	componentDidMount: function() {
		logger.custom('View Loaded: Shuttle Stop');
		// Stop placeholder render
		// Revisit at a later time
		InteractionManager.runAfterInteractions(() => {
			this.fetchShuttleArrivalsByStop('auto');
			 this.loadMapView();

			// Poll for new data
			this.refreshShuttleDataTimer = this.setTimeout( () => { this.fetchShuttleArrivalsByStop('auto') }, this.shuttleRefreshInterval);
			this.mapViewTimeout = this.setTimeout( () => { this.loadMapView() }, this.delayMapViewLoad);
			this.watchID = navigator.geolocation.watchPosition((currentPosition) => {
				this.setState({currentPosition});
			});
			this.setState({loaded: true});
		});
	},

	componentWillUnmount: function() {
		console.log("unmount shuttle");
		this.clearTimeout(this.mapViewTimeout);
		navigator.geolocation.clearWatch(this.watchID);
		this.setState({ mapViewLoadReady: false });
		this.forceUpdate();
	},

	render: function() {
		console.log("render shuttle");
		if(!this.state.loaded) {
			return this._renderPlaceholderView();
		}
		return this.renderScene();
	},

	/* Revisit after welcome week deadline
	   skeleton render for smoother transition*/
	_renderPlaceholderView: function() {
		return (
			<View style={[css.main_container, css.offwhitebg]}>

				<ScrollView contentContainerStyle={css.scroll_default}>

        			{this.state.shuttleStopImageDict[this.state.shuttleStopID] ? (
						<Image style={css.shuttlestop_image} source={ this.state.shuttleStopImageDict[this.state.shuttleStopID] } />
					) : null }
					
					<View style={css.shuttlestop_name_container}>
						<Text style={css.shuttlestop_name_text}>{this.state.shuttleStopName}</Text>
					</View>

					
					<View style={css.shuttle_stop_arrivals_container}>
						<Text style={css.shuttle_stop_next_arrivals_text}>There are no active shuttles at this time</Text>
					</View>

					<View>
						<Text style={css.shuttle_stop_map_text}>Map</Text>
					</View>

				</ScrollView>
			</View>
			
		);
	},

	renderScene: function(route, navigator) {
		return (
			<View style={[css.main_container, css.offwhitebg]}>

				<ScrollView contentContainerStyle={css.scroll_default} refreshControl={
					<RefreshControl
						refreshing={this.state.isRefreshing}
						onRefresh={this.refreshShuttleArrivalsByStop}
						tintColor="#CCC"
						title=""
					/>
        		}>

        			{this.state.shuttleStopImageDict[this.state.shuttleStopID] ? (
						<Image style={css.shuttlestop_image} source={ this.state.shuttleStopImageDict[this.state.shuttleStopID] } />
					) : null }

					<View style={css.shuttlestop_name_container}>
						<Text style={css.shuttlestop_name_text}>{this.state.shuttleStopName}</Text>

						<View style={css.shuttlestop_refresh_container}>
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.refreshShuttleArrivalsByStop('manual') }>
								<Animated.Image style={[css.shuttlestop_refresh, { transform: [{ rotate: this.shuttleReloadAnim.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '360deg']})}]}]} source={require('../assets/img/icon_refresh.png')} />
							</TouchableHighlight>
						</View>
					</View>

					{this.state.closestShuttlesInactive == false ? (
						<View>
							{this.state.closestShuttlesLoaded ? (
								<View style={css.shuttle_stop_arrivals_container}>
									<Text style={css.shuttle_stop_next_arrivals_text}>Next Arrivals</Text>
									{responseDataRef.length >= 1 ? (
										<View style={css.shuttle_stop_arrivals_row}>
											<View style={[css.shuttle_stop_rt_2, { backgroundColor: responseDataRef[responseDataSortRef[0].key].route.color, borderColor: responseDataRef[responseDataSortRef[0].key].route.color }]}><Text style={css.shuttle_stop_rt_2_label}>{responseDataRef[responseDataSortRef[0].key].route.shortName}</Text></View>
											<Text style={css.shuttle_stop_arrivals_row_route_name}>{responseDataRef[responseDataSortRef[0].key].route.name}</Text>
											<Text style={css.shuttle_stop_arrivals_row_eta_text}>{responseDataRef[responseDataSortRef[0].key].etaMinutes}</Text>
										</View>
									) : null }

									{responseDataRef.length >= 2 ? (
										<View style={css.shuttle_stop_arrivals_row}>
											<View style={[css.shuttle_stop_rt_2, { backgroundColor: responseDataRef[responseDataSortRef[1].key].route.color, borderColor: responseDataRef[responseDataSortRef[1].key].route.color }]}><Text style={css.shuttle_stop_rt_2_label}>{responseDataRef[responseDataSortRef[1].key].route.shortName}</Text></View>
											<Text style={css.shuttle_stop_arrivals_row_route_name}>{responseDataRef[responseDataSortRef[1].key].route.name}</Text>
											<Text style={css.shuttle_stop_arrivals_row_eta_text}>{responseDataRef[responseDataSortRef[1].key].etaMinutes}</Text>
										</View>
									) : null }

									{responseDataRef.length >= 3 ? (
										<View style={css.shuttle_stop_arrivals_row}>
											<View style={[css.shuttle_stop_rt_2, { backgroundColor: responseDataRef[responseDataSortRef[2].key].route.color, borderColor: responseDataRef[responseDataSortRef[2].key].route.color }]}><Text style={css.shuttle_stop_rt_2_label}>{responseDataRef[responseDataSortRef[2].key].route.shortName}</Text></View>
											<Text style={css.shuttle_stop_arrivals_row_route_name}>{responseDataRef[responseDataSortRef[2].key].route.name}</Text>
											<Text style={css.shuttle_stop_arrivals_row_eta_text}>{responseDataRef[responseDataSortRef[2].key].etaMinutes}</Text>
										</View>
									) : null }
								</View>
							) : (
								<ActivityIndicator style={css.shuttlestop_aa} size="small" />
							)}
						</View>
					) : (
						<View style={css.shuttle_stop_arrivals_container}>
							<Text style={css.shuttle_stop_next_arrivals_text}>There are no active shuttles at this time</Text>
						</View>
					)}
					
					
					{this.state.mapViewLoadReady ? (
						<MapView
							style={css.shuttlestop_map}
							loadingEnabled={true}
							loadingIndicatorColor={'#666'}
							loadingBackgroundColor={'#EEE'}
							showsUserLocation={true}
							mapType={'standard'}
							initialRegion={{
								latitude: Number(this.getCurrentPosition('lat')),
								longitude: Number(this.getCurrentPosition('lon')),
								latitudeDelta: this.state.mapDelta,
								longitudeDelta: this.state.mapDelta,
							}}>

							<MapView.Marker
								coordinate={{latitude: this.state.shuttleStopLat,
									longitude: this.state.shuttleStopLon}}
								title={this.state.shuttleStopName}
								description={this.state.shuttleStopName}
								key={this.state.shuttleStopName}
							/>
						</MapView>
					) : null }
				</ScrollView>
			</View>
			
		);
	},


	refreshShuttleArrivalsByStop: function(refreshType) {
		this.fetchShuttleArrivalsByStop(refreshType);
	},

	getCurrentPosition: function(type) {
		if (type === 'lat') {
			if (this.state.currentPosition) {
				return this.state.currentPosition.coords.latitude;
			} else {
				return this.state.defaultPosition.coords.latitude;
			}
		} else if (type === 'lon') {
			if (this.state.currentPosition) {
				return this.state.currentPosition.coords.longitude;
			} else {
				return this.state.defaultPosition.coords.longitude;
			}
		}
	},

	// TODO: use setState less, revisit when we have maps working
	loadMapView: function() {
		var distLatLon = Math.sqrt(Math.pow(Math.abs(this.getCurrentPosition('lat') - this.state.shuttleStopLat), 2) + Math.pow(Math.abs(this.getCurrentPosition('lon') - this.state.shuttleStopLon), 2));
		this.setState({
			mapDelta: distLatLon * 3
		});

		if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
			this.setState({ mapViewLoadReady: false });
		}
		else {
			this.setState({ mapViewLoadReady: true });
		}
		
	},

	fetchShuttleArrivalsByStop: function(fetchType) {

		responseDataSort = [];
		
		this.shuttleRefreshTimestamp = general.getCurrentTimestamp();

		if (this.state.closestShuttlesLoaded) {
			general.stopReloadAnimation(this.shuttleReloadAnim);
			general.startReloadAnimation(this.shuttleReloadAnim);
		}

		var SHUTTLE_STOPS_API_URL = AppSettings.SHUTTLE_STOPS_API_URL + this.state.shuttleStopID + '/arrivals';

		fetch(SHUTTLE_STOPS_API_URL, {
				method: 'GET',
				headers: {
					'Accept' : 'application/json',
					'Cache-Control': 'no-cache'
				}
			})
			.then((response) => response.json())
			.then((responseData) => {
				//logger.log("Fetch: " + JSON.stringify(responseData));
				general.stopReloadAnimation(this.shuttleReloadAnim);
				this._processShuttleArrivals(responseData);
			})
			.catch((error) => {
				logger.log('ERR2: fetchShuttleArrivalsByStopDetail: ' + error);
				this.setState({ closestShuttlesInactive: true });
				general.stopReloadAnimation(this.shuttleReloadAnim);
			})
			.done();
	},

	_processShuttleArrivals: function(data) {
		if (data.length > 0) {

			for (var i = 0; data.length > i; i++) {
				data[i].etaMinutes = shuttle.getMinutesETA(data[i].secondsToArrival);
				data[i].route.name = data[i].route.name.replace(/.*\) /, '').replace(/ - .*/, '');
				if (data[i].route.shortName == "Campus Loop") {
					data[i].route.shortName = "L";
				}
			}

			// Sort the results by lowest ETA
			for (var key in data) {
				responseDataSort.push({key:key, secondsToArrival:data[key].secondsToArrival});
			}

			responseDataSort.sort(function(x,y) { return x.secondsToArrival - y.secondsToArrival } );

			responseDataRef = data;
			responseDataSortRef = responseDataSort;

			this.setState({ closestShuttlesLoaded: true, closestShuttlesInactive: false});
		} else {
			throw('Invalid data');
		}
	}

});

module.exports = ShuttleStop;