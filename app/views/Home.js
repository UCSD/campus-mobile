'use strict';

import React from 'react';
import {
	StyleSheet,
	View,
	Text,
	AppState,
	TouchableHighlight,
	ScrollView,
	Image,
	ListView,
	Animated,
	RefreshControl,
	Modal,
	Component,
	Alert,
} from 'react-native';

// Cards
import EventCard from './events/EventCard'
import TopStoriesCard from './topStories/TopStoriesCard';
import WeatherCard from './weather/WeatherCard';

// Node Modules
var TimerMixin = 		require('react-timer-mixin');
var Realm = 			require('realm');
var MapView = 			require('react-native-maps');

// App Settings / Util / CSS
var AppSettings = 		require('../AppSettings');
var css = 				require('../styles/css');
var general = 			require('../util/general');
var logger = 			require('../util/logger');
var shuttle = 			require('../util/shuttle');

// UCSD Nodes / Shuttles
var ucsd_nodes = 		require('../json/ucsd_nodes.json');
var shuttle_routes = 	require('../json/shuttle_routes_master.json');

// Views
var ShuttleStop = 		require('./ShuttleStop');
var DestinationDetail = require('./DestinationDetail');
var DiningList = 		require('./DiningList');
var WebWrapper = 		require('./WebWrapper');

const Permissions = require('react-native-permissions');

import WelcomeWeekView from './welcomeWeek/WelcomeWeekView';

var Home = React.createClass({

	realm: null,
	AppSettings: null,
	mixins: [TimerMixin],
	permissionUpdateInterval: 5 * 1000,				// Update permissions every 5 seconds
	shuttleCardRefreshInterval: 1 * 60 * 1000,		// Refresh ShuttleCard every 1 minute
	shuttleCardGPSRefreshInterval: .25 * 1000,		// Look for GPS data every 250ms (1/4s) for 15s before failing
	shuttleCardGPSRefreshLimit: 60,
	shuttleReloadAnim: new Animated.Value(0),
	shuttleClosestStops: [{ dist: 100000000 },{ dist: 100000000 }],
	diningDefaultResults: 3,
	nearbyMaxResults: 5,
	regionRefreshInterval: 60 * 1000,				// Update region every 1 minute
	copyrightYear: new Date().getFullYear(),

	getInitialState: function() {

		return {
			currentAppState: AppState.currentState,
			modalVisible: true,
			welcomeWeekEnabled: false,
			currentRegion: null,
			nearbyMarkersLoaded: false,
			nearbyLastRefresh: null,
			specialEventsCardEnabled: true,
			scrollEnabled: true,

			diningDataLoaded: false,
			diningRenderAllRows: false,
			closestStop1Loaded: false,
			closestStop2Loaded: false,
			closestStop1LoadFailed: false,
			closestStop2LoadFailed: false,
			gpsLoadFailed: false,
			nearbyAnnotations: null,
			nearbyLatDelta: .02,
			nearbyLonDelta: .02,
			locationPermission: 'undetermined',
			currentPosition: null,
			defaultPosition: {
				coords: { latitude: 32.88, longitude: -117.234 }
			},
		}
	},

	componentWillMount: function() {

		// Realm DB Init
		this.realm = new Realm({schema: [AppSettings.DB_SCHEMA], schemaVersion: 2});
		this.AppSettings = this.realm.objects('AppSettings');

		// Hide welcome modal if previously dismissed
		if (this.AppSettings.MODAL_ENABLED === false) {
			this.setState({ modalVisible: false });
		}

		// Check welcome week date range - Activate from Aug 1 to Sep 24
		var currentYear = general.getTimestamp('yyyy');
		var currentMonth = general.getTimestamp('m');
		var currentDay = general.getTimestamp('d');
		if ((currentYear == 2016) && ((currentMonth == 8) || (currentMonth == 9 && currentDay <= 24))) {
			this.setState({ welcomeWeekEnabled: true });
		}

		// Manage App State
		AppState.addEventListener('change', this.handleAppStateChange);

		// Check Location Permissions Periodically
		this.updateLocationPermission();

		this.geolocationWatchID = navigator.geolocation.watchPosition((currentPosition) => {
			this.setState({ currentPosition });
		});

		// Load all non-broken-out Cards
		this.refreshAllCards('auto');
	},

	componentDidMount: function() {
		logger.custom('View Loaded: Home');
	},

	componentWillUnmount: function() {

		// Update unmount function with ability to clear all other timers (setTimeout/setInterval)

		navigator.geolocation.clearWatch(this.geolocationWatchID);
		AppState.removeEventListener('change', this.handleAppStateChange);
	},

	componentDidUpdate: function() {

	},

	updateLocationPermission: function() {
		// Get location permission status
		//logger.log('Checking permissions for Location...');

		Permissions.getPermissionStatus('location')
		.then(response => {
			//logger.log('Location permissions: ' + response);

			//response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
			this.setState({ locationPermission: response });
		});

		this.permissionUpdateTimer = this.setTimeout( () => { this.updateLocationPermission() }, this.permissionUpdateInterval);
	},

	// #1 - RENDER
	render: function() {
		return this.renderScene();
	},

	renderScene: function(route, navigator, index, navState) {

		return (
			<View style={css.main_container}>
				<ScrollView contentContainerStyle={css.scroll_main}>

					{this.AppSettings['0'].MODAL_ENABLED ? (
						<Modal animationType={'none'} transparent={true} visible={this.state.modalVisible}>
							<View style={css.modal_container}>
								<Text style={css.modal_text_intro}>Hello.</Text>
								<Text style={css.modal_text}>
									Thanks for trying {AppSettings.APP_NAME}!{'\n\n'}
									{AppSettings.APP_NAME} connects you to campus with:{'\n\n'}
									- location-based shuttle information{'\n'}
									- timely news and events{'\n'}
									- nearby points of interest{'\n'}
									- and we&apos;ll be adding new stuff all the time{'\n'}
								</Text>

								<TouchableHighlight underlayColor={'rgba(200,200,200,.5)'} onPress={ () => this.setModalVisible(false) }>
									<View style={css.modal_button}>
										<Text style={css.modal_button_text}>ok, let&apos;s go already</Text>
									</View>
								</TouchableHighlight>
							</View>
						</Modal>
					) : null }



					{/* SPECIAL EVENTS CARD */}
					{/*<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoWebView('Welcome Week', AppSettings.WELCOME_WEEK_URL) }>*/}
					{this.state.welcomeWeekEnabled ? (
						<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoWelcomeWeekView() }>
							<Image style={[css.card_plain, css.card_special_events]} source={ require('../assets/img/welcome_week.jpg') } />
						</TouchableHighlight>
					) : null }


					{/* SHUTTLE CARD */}
					{AppSettings.SHUTTLE_CARD_ENABLED ? (
						<View style={css.card_main}>
							<View style={css.card_title_container}>
								<Text style={css.card_title}>Shuttle Routes</Text>
								<View style={css.shuttle_card_refresh_container}>
									<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.refreshShuttleCard('manual') }>
										<Animated.Image style={[css.shuttle_card_refresh, { transform: [{ rotate: this.shuttleReloadAnim.interpolate({ inputRange: [0, 1], outputRange: ['0deg', '360deg']})}]}]} source={require('../assets/img/icon_refresh_grey.png')} />
									</TouchableHighlight>
								</View>
							</View>

							{this.state.closestStop1Loaded ? (
								<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoShuttleStop(this.shuttleClosestStops[0]) }>
									<View style={css.shuttle_card_row}>
										<View style={css.shuttle_card_row_top}>
											<View style={css.shuttle_card_rt_1}></View>
											<View style={[css.shuttle_card_rt_2, { backgroundColor: this.shuttleClosestStops[0].routeColor, borderColor: this.shuttleClosestStops[0].routeColor }]}><Text style={css.shuttle_card_rt_2_label}>{this.shuttleClosestStops[0].routeShortName}</Text></View>
											<View style={css.shuttle_card_rt_3}><Text style={css.shuttle_card_rt_3_label}>@</Text></View>
											<View style={css.shuttle_card_rt_4}><Text style={css.shuttle_card_rt_4_label} numberOfLines={3}>{this.shuttleClosestStops[0].stopName}</Text></View>
											<View style={css.shuttle_card_rt_5}></View>
										</View>
										<View style={css.shuttle_card_row_bot}>
											<Text style={css.shuttle_card_row_arriving}><Text style={css.grey}>Arriving in: </Text>{this.shuttleClosestStops[0].etaMinutes}</Text>
										</View>
									</View>
								</TouchableHighlight>
							) : null }

							{this.state.closestStop2Loaded ? (
								<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoShuttleStop(this.shuttleClosestStops[1]) }>
									<View style={[css.shuttle_card_row, css.shuttle_card_row_border]}>
										<View style={css.shuttle_card_row_top}>
											<View style={css.shuttle_card_rt_1}></View>
											<View style={[css.shuttle_card_rt_2, { backgroundColor: this.shuttleClosestStops[1].routeColor, borderColor: this.shuttleClosestStops[1].routeColor }]}><Text style={css.shuttle_card_rt_2_label}>{this.shuttleClosestStops[1].routeShortName}</Text></View>
											<View style={css.shuttle_card_rt_3}><Text style={css.shuttle_card_rt_3_label}>@</Text></View>
											<View style={css.shuttle_card_rt_4}><Text style={css.shuttle_card_rt_4_label} numberOfLines={3}>{this.shuttleClosestStops[1].stopName}</Text></View>
											<View style={css.shuttle_card_rt_5}></View>
										</View>
										<View style={css.shuttle_card_row_bot}>
											<Text style={css.shuttle_card_row_arriving}><Text style={css.grey}>Arriving in: </Text>{this.shuttleClosestStops[1].etaMinutes}</Text>
										</View>
									</View>
								</TouchableHighlight>
							) : null }

						</View>
					) : null }

					{/* EVENTS CARD & TOP STORIES CARD & WEATHER CARD */}
					{ this.getCards() }

					{/* NEARBY CARD */}
					{AppSettings.NEARBY_CARD_ENABLED ? (
						<View style={css.card_main}>
							<View style={css.card_title_container}>
								<Text style={css.card_title}>Nearby</Text>
							</View>

							<View style={css.destinationcard_bot_container}>
								<View style={css.destinationcard_map_container}>
									
									{this.state.nearbyAnnotations ? (

										<MapView
											style={css.destinationcard_map}
											loadingEnabled={true}
											loadingIndicatorColor={'#666'}
											loadingBackgroundColor={'#EEE'}
											showsUserLocation={true}
											mapType={'terrain'}
											initialRegion={{
												latitude: this.getCurrentPosition('lat'),
												longitude: this.getCurrentPosition('lon'),
												latitudeDelta: this.state.nearbyLatDelta,
												longitudeDelta: this.state.nearbyLonDelta,
											}}>
												{this.state.nearbyAnnotations.map(marker => (
													<MapView.Marker
													coordinate={marker.coords}
													title={marker.title}
													description={marker.description}
													/>
												))}
										</MapView>
									) : null }

								</View>

								{this.state.nearbyMarkersLoaded ? (
									<ListView dataSource={this.state.nearbyMarkersPartial} renderRow={this.renderNearbyRow} style={css.flex} />
								) : null }
							</View>
						</View>
					) : null }


					{/* DINING CARD */}
					{AppSettings.DINING_CARD_ENABLED ? (
						<View>
							<View style={css.card_main}>
								<View style={css.card_title_container}>
									<Text style={css.card_title}>Dining</Text>
								</View>

								{this.state.diningDataLoaded ? (
									<View style={css.dining_card}>
										<View style={css.dining_card_map}>

											{/*<MapView
												style={css.destinationcard_map}
												scrollEnabled={true}
												zoomEnabled={true}
												rotateEnabled={false}
												showsUserLocation={true}
												minDelta={this.nearbyMinDelta}
												maxDelta={this.nearbyMaxDelta}
												followUserLocation={true} />*/}
										</View>

										<View style={css.dining_card_filters}>
											<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.updateDiningFilters('vegetarian') }>
												<Text style={css.dining_card_filter_button}>Vegetarian</Text>
											</TouchableHighlight>

											<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.updateDiningFilters('vegan') }>
												<Text style={css.dining_card_filter_button}>Vegan</Text>
											</TouchableHighlight>

											<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.updateDiningFilters('glutenfree') }>
												<Text style={css.dining_card_filter_button}>Gluten-free</Text>
											</TouchableHighlight>

											<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.updateDiningFilters('opennow') }>
												<Text style={css.dining_card_filter_button}>Open Now</Text>
											</TouchableHighlight>
										</View>

										<View style={css.dc_locations}>
											<ListView dataSource={this.state.diningDataFull} renderRow={this.renderDiningRow} style={css.wf_listview} />
										</View>



									</View>
								) : null }
							</View>




						</View>
					) : null }


					{/* FOOTER */}
					<View style={css.footer}>
						<TouchableHighlight style={css.footer_link} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoFeedbackForm() }>
							<Text style={css.footer_about}>About this app</Text>
						</TouchableHighlight>
						<Text style={css.footer_spacer}>|</Text>
						<TouchableHighlight style={css.footer_link}>
							<Text style={css.footer_copyright}>&copy; {this.copyrightYear} UC Regents</Text>
						</TouchableHighlight>
					</View>

				</ScrollView>
			</View>
		);
	},

	getCards: function(){
		var cards = [];
		var cardCounter = 0;
		// Setup CARDS
		// Keys need to be unique, there's probably a better solution, but this works for now
		if (AppSettings.WEATHER_CARD_ENABLED){
			cards.push(<WeatherCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={this._generateUUID + ':' + cardCounter++}/>);
		}
		if (AppSettings.TOPSTORIES_CARD_ENABLED){
			cards.push(<TopStoriesCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={this._generateUUID + ':' + cardCounter++}/>);
		}
		if (AppSettings.EVENTS_CARD_ENABLED){
			cards.push(<EventCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={this._generateUUID + ':' + cardCounter++}/>);
		}
		return cards;
	},



	// #2 - REFRESH
	refreshAllCards: function(refreshType) {
		if (!refreshType) {
			refreshType = 'manual';
		}

		// Use default location (UCSD) if location permissions disabled
		this.refreshShuttleCard(refreshType);
		this.refreshNearbyCard();
		this.refreshDiningCard();

		// Refresh broken out cards
		// Top Stories, Events, Weather
		if (this.refs.cards) {
			this.refs.cards.forEach(c => c.refresh());
		}
	},

	refreshShuttleCard: function(refreshType) {
		if (AppSettings.SHUTTLE_CARD_ENABLED) {
			this.findClosestShuttleStops(refreshType);
		}
	},

	refreshNearbyCard: function() {
		if (AppSettings.NEARBY_CARD_ENABLED) {
			this.updateCurrentNodeRegion();
		}
	},

	refreshDiningCard: function() {
		if (AppSettings.DINING_CARD_ENABLED) {
			this.fetchDiningLocations();
		}
	},

	fetchDiningLocations: function() {
		fetch(AppSettings.DINING_API_URL, {
				headers: {
					'Cache-Control': 'no-cache'
				}
			})
			.then((response) => response.json())
			.then((responseData) => {

				responseData = responseData.GetDiningInfoResult;

				// Calc distance from dining locations
				for (var i = 0; responseData.length > i; i++) {
					var distance = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), responseData[i].coords.lat, responseData[i].coords.lon);
					if (distance) {
						responseData[i].distance = distance;
					} else {
						responseData[i].distance = 100000000;
					}
				}

				// Sort dining locations by distance
				responseData.sort(this.sortNearbyMarkers);

				// remove after 'more' button functionality added
				responseData.length = 4;

				var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

				this.setState({
					diningData: responseData,
					diningDataFull: dsFull.cloneWithRows(responseData),
					diningDataLoaded: true
				});
			})
			.catch((error) => {
				logger.log('ERR: fetchDiningLocations: ' + error)
			})
			.done();
	},


	renderDiningRow: function(data) {

		var currentTimestamp = general.getTimestamp('yyyy-mm-dd');
		var diningHours = '';
		var dayOfWeek = general.getTimestamp('ddd').toLowerCase();

		if (data.specialHours[currentTimestamp]) {
			diningHours = data.specialHours[currentTimestamp];
		} else {
			diningHours = data.regularHours.join("\n");
		}


		/* Re-enable once dining info feed open hours are fixed
		if (data.specialHours[currentTimestamp]) {
			diningHours = data.specialHours[currentTimestamp];
		} else if (data.regularHours[dayOfWeek].indexOf('closed') === 0) {
			diningHours = 'Closed';
		} else {
			var openHours, openTime, closeTime;
			openHours = data.regularHours[dayOfWeek].split('-');
			openTime = general.militaryToAMPM(openHours[0]);
			closeTime = general.militaryToAMPM(openHours[1]);
			diningHours = 'Open ' + openTime + '-' + closeTime;
		}
		*/

		return (
			<View style={css.dc_locations_row}>
				<TouchableHighlight style={css.dc_locations_row_left} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningList(data) }>
					<View>
						<Text style={css.dc_locations_title}>{data.name}</Text>
						<Text style={css.dc_locations_hours}>{diningHours}</Text>
						{/*<Text style={css.dc_locations_description}>{data.description}</Text>*/}
					</View>
				</TouchableHighlight>
				{data.email ? (
					<TouchableHighlight style={css.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.openEmailLink(data.email) }>
						<View>
							<Image style={css.dc_locations_email_icon} source={ require('../assets/img/icon_email.png')} />

							<Text style={css.dc_locations_email}>Email</Text>
						</View>
					</TouchableHighlight>
				) : (
					<View style={css.dc_locations_row_right}></View>
				)}
			</View>
		);
	},


	updateDiningFilters: function(filter) {

		/*
		var diningData = this.state.diningData;
		var diningDataLength = diningData.length;

		logger.log('diningDataLength: ' + diningDataLength)

		for (var i = 0; diningDataLength > i; i++) {

			var diningTags = diningData[i].tags.split(',');
			logger.log('diningTags:');
			logger.log(diningTags)

			for (var n = 0; diningTags.length > n; n++) {
				if (diningTags[n] === filter) {
					logger.log('deleting diningData' + i);
					//diningData.splice(i, 1);
					//i--;
					break;
				}
			}

		}

		var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		this.setState({
			diningDataFull: dsFull.cloneWithRows(diningData),
		});
		*/

		return null;

	},

	// #6 - NEARBY CARD
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

	// Updates which predesignated node region the user is in
	updateCurrentNodeRegion: function() {

		var closestNode = 0;
		var closestNodeDistance = 100000000;

		for (var i = 0; ucsd_nodes.length > i; i++) {
			var nodeDist = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), ucsd_nodes[i].lat, ucsd_nodes[i].lon);

			if (nodeDist < closestNodeDistance) {
				closestNodeDistance = nodeDist;
				closestNode = ucsd_nodes[i].id;
			}
		}

		this.setState({ currentRegion: closestNode });

		var NODE_MODULES_URL = AppSettings.NODE_MARKERS_BASE_URL + 'ucsd_node_' + closestNode + '.json';

		logger.log('updateCurrentNodeRegion:')

		fetch(NODE_MODULES_URL, {
				method: 'GET',
			})
			.then((response) => response.json())
			.then((responseData) => {
				this.parseNodeRegion(responseData);
			})
			.catch((error) => {
				logger.custom('ERR: loadNodeRegion: ' + error);
			})
			.done();

		this.updateCurrentNodeRegionTimer = this.setTimeout( () => { this.updateCurrentNodeRegion() }, this.regionRefreshInterval);
	},

	parseNodeRegion: function(ucsd_node) {
		// Calc distance from markers
		for (var i = 0; ucsd_node.length > i; i++) {
			ucsd_node[i].distance = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), ucsd_node[i].mkrLat, ucsd_node[i].mkrLong);
		}

		ucsd_node.sort(this.sortNearbyMarkers);
		var nodeDataFull = ucsd_node;
		var nodeDataPartial = ucsd_node.slice(0, this.nearbyMaxResults);

		var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
		var dsPartial = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		var farthestMarkerDist;

		var nearbyAnnotations = [];
		for (var i = 0; ucsd_node.length > i && this.nearbyMaxResults > i; i++) {
			if (this.nearbyMaxResults === i + 1) {
				farthestMarkerDist = ucsd_node[i].distance;
				var distLatLon = Math.sqrt(Math.pow(Math.abs(this.getCurrentPosition('lat') - ucsd_node[i].mkrLat), 2) + Math.pow(Math.abs(this.getCurrentPosition('lon') - ucsd_node[i].mkrLong), 2));
				this.setState({
					nearbyLatDelta: distLatLon * 2.5,
					nearbyLonDelta: distLatLon * 2.5
				});
			}

			var newAnnotations = {};
			
			newAnnotations.coords = {
				latitude: parseFloat(ucsd_node[i].mkrLat),
				longitude: parseFloat(ucsd_node[i].mkrLong)
			};
			

			newAnnotations.latitude = parseFloat(ucsd_node[i].mkrLat);
			newAnnotations.longitude = parseFloat(ucsd_node[i].mkrLong);
			newAnnotations.title = ucsd_node[i].title;
			newAnnotations.description = ucsd_node[i].description;
			nearbyAnnotations.push(newAnnotations);
		}

		logger.log('updateCurrentNodeRegion: complete')

		this.setState({
			nearbyAnnotations: nearbyAnnotations,
			nearbyMarkersFull: dsFull.cloneWithRows(nodeDataFull),
			nearbyMarkersPartial: dsPartial.cloneWithRows(nodeDataPartial),
			nearbyMarkersLoaded: true
		});
	},

	sortNearbyMarkers: function(a, b) {
		if (a.distance < b.distance) {
			return -1;
		} else if (a.distance > b.distance) {
			return 1;
		} else {
			return 0;
		}
	},

	renderNearbyRow: function(data) {
		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDestinationDetail(data) }>
				<View style={css.destinationcard_marker_row}>
					<Image style={css.destinationcard_icon_marker} source={require('../assets/img/icon_marker.png')} />
					<Text style={css.destinationcard_marker_label}>{data.title}</Text>
				</View>
			</TouchableHighlight>
		);
	},


	// SHUTTLE_CARD
	findClosestShuttleStops: function(refreshType) {

		// If running on Device, and no Current or Initial position exists, retry again in 5 sec
		if (!this.props.isSimulator && this.state.currentPosition === null) {

			general.stopReloadAnimation(this.shuttleReloadAnim);

			if (this.shuttleCardGPSRefreshCounter < this.shuttleCardGPSRefreshLimit) {
				this.shuttleCardGPSRefreshCounter++;
				//logger.log('Queueing Shuttle Card refresh (for GPS) in ' + this.shuttleCardGPSRefreshInterval/1000 + ' seconds');
				this.refreshShuttleCardTimer = this.setTimeout( () => { this.refreshShuttleCard('auto') }, this.shuttleCardGPSRefreshInterval);
			} else {
				//logger.log('Failed to obtain GPS data, setting closestStop1LoadFailed: true');
				this.setState({ gpsLoadFailed: true });
			}

		} else {

			this.shuttleCardGPSRefreshCounter = 0;
			this.shuttleRefreshTimestamp = general.getCurrentTimestamp();

			this.setState({
				closestStop1LoadFailed: false,
				closestStop2LoadFailed: false,
				shuttleRefreshTimeAgo: ' '
			});

			this.shuttleClosestStops[0].dist = 1000000000;
			this.shuttleClosestStops[1].dist = 1000000000;

			for (var i = 0; shuttle_routes.length > i; i++) {

				var shuttleRoute = shuttle_routes[i];

				for (var n = 0; shuttleRoute.stops.length > n; n++) {

					var shuttleRouteStop = shuttleRoute.stops[n];
					var distanceFromStop = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), shuttleRouteStop.lat, shuttleRouteStop.lon);

					// Rewrite this later using sortRef from shuttleDetail
					if (distanceFromStop < this.shuttleClosestStops[0].dist) {
						this.shuttleClosestStops[0].stopID = shuttleRouteStop.id;
						this.shuttleClosestStops[0].stopName = shuttleRouteStop.name;
						this.shuttleClosestStops[0].dist = distanceFromStop;
						this.shuttleClosestStops[0].stopLat = shuttleRouteStop.lat;
						this.shuttleClosestStops[0].stopLon = shuttleRouteStop.lon;
					} else if (distanceFromStop < this.shuttleClosestStops[1].dist && this.shuttleClosestStops[0].stopID != shuttleRouteStop.id) {
						this.shuttleClosestStops[1].stopID = shuttleRouteStop.id;
						this.shuttleClosestStops[1].stopName = shuttleRouteStop.name;
						this.shuttleClosestStops[1].dist = distanceFromStop;
						this.shuttleClosestStops[1].stopLat = shuttleRouteStop.lat;
						this.shuttleClosestStops[1].stopLon = shuttleRouteStop.lon;
					}
				}
			}

			this.fetchShuttleArrivalsByStop(0, this.shuttleClosestStops[0].stopID);
			this.fetchShuttleArrivalsByStop(1, this.shuttleClosestStops[1].stopID);

			if (refreshType == 'auto') {
				//logger.log('Queueing Shuttle Card data refresh in ' + this.shuttleCardRefreshInterval/1000 + ' seconds');
				this.refreshShuttleCardTimer = this.setTimeout( () => { this.refreshShuttleCard('auto') }, this.shuttleCardRefreshInterval);
			} else {
				// If manual refresh, reset the Auto refresh timer
				this.clearTimeout(this.refreshShuttleCardTimer);
				this.refreshShuttleCardTimer = this.setTimeout( () => { this.refreshShuttleCard('auto') }, this.shuttleCardRefreshInterval);
			}
		}
	},

	fetchShuttleArrivalsByStop: function(closestStopNumber, stopID) {

		var SHUTTLE_STOPS_API_URL = AppSettings.SHUTTLE_STOPS_API_URL + stopID + '/arrivals';
		logger.log("Shuttle link: " + SHUTTLE_STOPS_API_URL);
		fetch(SHUTTLE_STOPS_API_URL, {
				method: 'GET',
				headers: {
					'Accept' : 'application/json',
					'Cache-Control': 'no-cache'
				}
			})
			.then((response) => response.json())
			.then((responseData) => {

				if (responseData.length > 0 && responseData[0].secondsToArrival) {

					var closestShuttleETA = 999999;

					for (var i = 0; responseData.length > i; i++) {

						var shuttleStopArrival = responseData[i];

						if (shuttleStopArrival.secondsToArrival < closestShuttleETA ) {
							closestShuttleETA = shuttleStopArrival.secondsToArrival;

							this.shuttleClosestStops[closestStopNumber].etaMinutes = shuttle.getMinutesETA(responseData[i].secondsToArrival);
							this.shuttleClosestStops[closestStopNumber].etaSeconds = shuttleStopArrival.secondsToArrival;
							this.shuttleClosestStops[closestStopNumber].routeID = shuttleStopArrival.route.id;
							this.shuttleClosestStops[closestStopNumber].routeName = shuttleStopArrival.route.name;
							this.shuttleClosestStops[closestStopNumber].routeShortName = shuttleStopArrival.route.shortName;
							this.shuttleClosestStops[closestStopNumber].routeColor = shuttleStopArrival.route.color;
						}
					}

					if (this.shuttleClosestStops[closestStopNumber].routeShortName == "Campus Loop") {
						this.shuttleClosestStops[closestStopNumber].routeShortName = "L";
					}
					this.shuttleClosestStops[closestStopNumber].routeName = this.shuttleClosestStops[closestStopNumber].routeName.replace(/.*\) /, '').replace(/ - .*/, '');

					if (closestStopNumber == 0) {
						this.setState({ closestStop1Loaded: true });
					} else if (closestStopNumber == 1) {
						this.setState({ closestStop2Loaded: true });
					}

				} else {
					throw('invalid');
				}

				general.stopReloadAnimation(this.shuttleReloadAnim);

			})
			.catch((error) => {

				logger.custom('ERR: fetchShuttleArrivalsByStop: ' + error + ' (stop: ' + closestStopNumber + ')');

				if (closestStopNumber == 0) {
					this.setState({ closestStop1LoadFailed: true });
				} else if (closestStopNumber == 1) {
					this.setState({ closestStop2LoadFailed: true });
				}

				general.stopReloadAnimation(this.shuttleReloadAnim);
			})
			.done();
	},

	gotoShuttleStop: function(stopData) {
		this.props.navigator.push({ id: 'ShuttleStop', component: ShuttleStop, title: 'Shuttle', stopData: stopData });
	},

	gotoDestinationDetail: function(destinationData) {
		destinationData.currentLat = this.getCurrentPosition('lat');
		destinationData.currentLon = this.getCurrentPosition('lon');

		destinationData.mkrLat = parseFloat(destinationData.mkrLat);
		destinationData.mkrLong = parseFloat(destinationData.mkrLong);

		destinationData.distLatLon = Math.sqrt(Math.pow(Math.abs(this.getCurrentPosition('lat') - destinationData.mkrLat), 2) + Math.pow(Math.abs(this.getCurrentPosition('lon') - destinationData.mkrLong), 2));
		this.props.navigator.push({ id: 'DestinationDetail', component: DestinationDetail, title: destinationData.title, destinationData: destinationData });
	},

	gotoWebView: function(title, url) {
		this.props.navigator.push({ id: 'WebWrapper', component: WebWrapper, title: title, webViewURL: url });
	},

	gotoFeedbackForm: function() {
		this.props.navigator.push({ id: 'WebWrapper', component: WebWrapper, title: 'Feedback', webViewURL: AppSettings.FEEDBACK_URL });
	},

	gotoPrivacyPolicy: function() {
		this.props.navigator.push({ id: 'WebWrapper', component: WebWrapper, title: 'About', webViewURL: AppSettings.PRIVACY_POLICY_URL });
	},

	gotoScheduleDetail: function() {
		this.props.navigator.push({ id: 'ScheduleDetail', component: ScheduleDetail, title: 'Schedule' });
	},

	gotoDiningList: function(marketData) {
		this.props.navigator.push({ id: 'DiningList', component: DiningList, title: marketData.name, marketData: marketData });
	},

	gotoWelcomeWeekView() {
  		this.props.navigator.push({ id: 'WelcomeWeekView', component: WelcomeWeekView, title: 'Welcome Week'});
	},


	// #99 - MISC
	openEmailLink: function(email) {
		Linking.canOpenURL(email).then(supported => {
			if (supported) {
				Linking.openURL('mailto:' + email);
			} else {
				logger.log('openEmailLink: Unable to send email to ' + email);
			}
		});
	},

	_setState: function(myKey, myVal) {
		var state = {};
		state[myKey] = myVal;
		this.setState(state);
	},

	// Welcome Modal
	setModalVisible: function(visible) {
		this.realm.write(() => {
			this.realm.create('AppSettings', { id: 1, MODAL_ENABLED: false }, true);
		});
		this.setState({ modalVisible: visible });
	},

	handleAppStateChange: function(currentAppState) {
		this.setState({ currentAppState, });
		if (currentAppState === 'active') {
			this.refreshAllCards('auto');
		}
	},

	// Generates a unique ID
	// Used for Card keys
	_generateUUID: function() {
		var d = new Date().getTime();
		if(window.performance && typeof window.performance.now === "function") {
			d += performance.now(); //use high-precision timer if available
		}
		var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
			var r = (d + Math.random()*16)%16 | 0;
			d = Math.floor(d/16);
			return (c=='x' ? r : (r&0x3|0x8)).toString(16);
		});
		return uuid;
	},

});

module.exports = Home;
