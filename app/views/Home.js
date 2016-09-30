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
	Navigator,
	ActivityIndicator,
	InteractionManager
} from 'react-native';

import TopBannerView from './banner/TopBannerView';
import WelcomeModal from './WelcomeModal';
import NavigationBarWithRouteMapper from './NavigationBarWithRouteMapper';

// Cards
import EventCard from './events/EventCard'
import NewsCard from './news/NewsCard';
import WeatherCard from './weather/WeatherCard';
import ShuttleCard from './shuttle/ShuttleCard';
import NearbyCard from './nearby/NearbyCard';

// Node Modules
import TimerMixin from 'react-timer-mixin';

const Permissions = 	require('react-native-permissions');
const GoogleAPIAvailability = 	require('react-native-google-api-availability-bridge');

// App Settings / Util / CSS
var AppSettings = 	require('../AppSettings');
var css = 			require('../styles/css');
var general = 		require('../util/general');
var logger = 		require('../util/logger');
var shuttle = 		require('../util/shuttle');

// Views
var DiningList = 	require('./DiningList');
var DiningDetail = 	require('./DiningDetail');
var WebWrapper = 	require('./WebWrapper');

var Home = React.createClass({

	mixins: [TimerMixin],
	permissionUpdateInterval: 1 * 65 * 1000,
	regionRefreshInterval: 1 * 70 * 1000,
	diningDefaultResults: 3,
	copyrightYear: new Date().getFullYear(),
	geolocationWatchID: null,

	getInitialState: function() {
		return {
			initialLoad: true,
			nearbyLastRefresh: null,
			specialEventsCardEnabled: true,
			scrollEnabled: true,
			diningDataLoaded: false,
			diningRenderAllRows: false,
			locationPermission: 'undetermined',
			currentPosition: null,
			defaultPosition: {
				coords: { latitude: 32.88, longitude: -117.234 }
			},
			cacheMap: false,
			loaded:false,
			refreshing:false,
			updatedGoogle: true,
		}
	},

	componentWillMount: function() {

		if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
			// Check Location Permissions Periodically
			this.updateLocationPermission();
			this.updateGooglePlay();
			this.setState({cacheMap: true});
		}

		else {
			this.setState({locationPermission: 'authorized'});
			navigator.geolocation.getCurrentPosition(
				(initialPosition) => { this.setState({currentPosition: initialPosition}) },
				(error) => logger.log('ERR: navigator.geolocation.getCurrentPosition: ' + error.message),
				{enableHighAccuracy: true, timeout: 20000, maximumAge: 1000}
			);
			this.geolocationWatchID = navigator.geolocation.watchPosition((currentPosition) => {
				let lastPos = this.state.currentPosition;
				this.setState({ currentPosition });

				// Initial refresh
				if(lastPos === null ) {
					this.refreshAllCards('auto');
				}
			});
		}
	},

	componentDidMount: function() {
		logger.ga('View Loaded: Home');
		InteractionManager.runAfterInteractions(() => {
			this.setTimeout(() => {this.setState({loaded: true});}, 2000);
		});
	},

	componentWillUnmount: function() {
		// Update unmount function with ability to clear all other timers (setTimeout/setInterval)
		navigator.geolocation.clearWatch(this.geolocationWatchID);
	},

	shouldComponentUpdate: function() {
		return true;
	},

	updateLocationPermission: function() {
		this.getLocationPermission();

		this.props.new_timeout("location", () => { this.updateLocationPermission() }, this.permissionUpdateInterval);
	},

	updateGooglePlay: function() {
		GoogleAPIAvailability.checkGooglePlayServices((result) => {
			if(result === 'update') {
				this.setState({updatedGoogle: false})
			}
		});
	},

	getLocationPermission: function() {
		// Get location permission status on Android
		Permissions.getPermissionStatus('location')
		.then(response => {
			//response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
			this.setState({ locationPermission: response });

			if (response === "authorized") {
				if(this.state.currentPosition === null ) {
					this.geolocationWatchID = navigator.geolocation.watchPosition((currentPosition) => {
						let lastPos = this.state.currentPosition;
						this.setState({ currentPosition });

						// Initial refresh
						if(lastPos === null ) {
							this.refreshAllCards('auto');
						}
					});
				}
				else {
					// Load all non-broken-out Cars
					this.refreshAllCards('auto');
				}

			} else {
				this._requestPermission();
				//this._alertForLocationPermission();
			}
		});
	},

	// Custom message, optional
	_alertForLocationPermission() {
		Alert.alert(
			'Allow this app to access your location?',
			'We need access so you can get nearby information.',
			[
				{text: 'No', onPress: () => logger.log('_alertForLocationPermission: location access denied'), style: 'cancel'},
				{text: 'Yes', onPress: this._requestPermission}
			]
		)
	},

	_requestPermission() {
	Permissions.requestPermission('location')
		.then(response => {
			//returns once the user has chosen to 'allow' or to 'not allow' access
			//response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
			this.setState({ locationPermission: response })
		});
	},

	// #1 - RENDER
	render: function() {
		logger.log('Home: render');
		return this.renderScene();
	},

	renderScene: function(route, navigator, index, navState) {
		return (
			<View style={css.main_container}>
				<ScrollView contentContainerStyle={css.scroll_main} refreshControl={
					<RefreshControl
						refreshing={this.state.refreshing}
						onRefresh={this._handleRefresh}
						tintColor="#CCC"
						title=""
					/>
				}>

					{/* WELCOME MODAL */}
					<WelcomeModal />

					{/* SPECIAL TOP BANNER */}
					<TopBannerView navigator={this.props.navigator}/>

					{/* DINING CARD */}
					{AppSettings.DINING_CARD_ENABLED ? (
						<View>
							<View style={css.card_main}>
								<View style={css.card_title_container}>
									<Text style={css.card_title}>Dining</Text>
								</View>

								{this.state.diningDataLoaded ? (
									<View style={css.dining_card}>
										<View style={css.dining_card_map}></View>
										<View style={css.dc_locations}>
											<ListView dataSource={this.state.diningDataPartial} renderRow={this.renderDiningRow} style={css.wf_listview} />
										</View>
										<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningList(this.state.diningData) }>
											<View style={css.events_more}>
												<Text style={css.events_more_label}>View All Locations</Text>
											</View>
										</TouchableHighlight>
									</View>
								) : (
									<View style={[css.shuttle_card_row_center, css.shuttle_card_loader]}>
										<ActivityIndicator style={css.shuttle_card_aa} size="large" />
									</View>
								)}
							</View>
						</View>
					) : null }

					{/* SHUTTLE_CARD & EVENTS CARD & NEWS CARD & WEATHER CARD & NEARBY CARD*/}
					{ this.getCards() }
					

					{/* FOOTER */}
					<View style={css.footer}>
						<TouchableHighlight style={css.footer_link} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoFeedbackForm() }>
							<Text style={css.footer_about}>Feedback</Text>
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
		if (AppSettings.SHUTTLE_CARD_ENABLED) {
			cards.push(<ShuttleCard navigator={this.props.navigator} location={this.state.currentPosition} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={this._generateUUID + ':' + cardCounter++} />);
		}
		if (AppSettings.WEATHER_CARD_ENABLED){
			cards.push(<WeatherCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={this._generateUUID + ':' + cardCounter++}/>);
		}
		if (AppSettings.EVENTS_CARD_ENABLED){
			cards.push(<EventCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={this._generateUUID + ':' + cardCounter++}/>);
		}
		if (AppSettings.NEWS_CARD_ENABLED){
			cards.push(<NewsCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={this._generateUUID + ':' + cardCounter++}/>);
		}
		if (AppSettings.NEARBY_CARD_ENABLED){
			cards.push(<NearbyCard navigator={this.props.navigator} getCurrentPosition={(latlon) => this.getCurrentPosition(latlon)} updatedGoogle={this.state.updatedGoogle}ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={this._generateUUID + ':' + cardCounter++}/>);
		}
		return cards;
	},



	// #2 - REFRESH
	refreshAllCards: function(refreshType) {
		if (!refreshType) {
			refreshType = 'manual';
		}

		if (AppSettings.SHUTTLE_CARD_ENABLED ) {
			// if we don't have location permissions, try to get them
			if(this.state.locationPermission !== 'authorized') {
				this.getLocationPermission();
			}
		}

		// Use default location (UCSD) if location permissions disabled
		this.refreshDiningCard();

		// Refresh broken out cards
		// Shuttle, News, Events, Weather, Nearby
		if (this.refs.cards) {
			this.refs.cards.forEach(c => c.refresh());
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
				var responseDataFinal = [],
					responseDataPartial = [];

				// Push dining locations with food entries to final list
				for (var i = 0; responseData.length > i; i++) {
					if (responseData[i].menuItems.length > 0) {
						responseDataFinal.push(responseData[i]);
					}
				}

				// Calc distance from dining locations
				for (var i = 0; responseDataFinal.length > i; i++) {
					var distance = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), responseDataFinal[i].coords.lat, responseDataFinal[i].coords.lon);
					if (distance) {
						responseDataFinal[i].distance = distance;
					} else {
						responseDataFinal[i].distance = 100000000;
					}
				}

				// Sort dining locations by distance
				responseDataFinal.sort(this.sortNearbyMarkers);
				responseDataPartial = responseDataFinal.slice(0, this.diningDefaultResults);



				var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

				this.setState({
					diningData: responseDataFinal,
					diningDataPartial: dsFull.cloneWithRows(responseDataPartial),
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

		return (
			<View style={css.dc_locations_row}>
				<TouchableHighlight style={css.dc_locations_row_left} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningDetail(data) }>
					<View>
						<Text style={css.dc_locations_title}>{data.name}</Text>
						<Text style={css.dc_locations_hours}>{diningHours}</Text>
					</View>
				</TouchableHighlight>

				{data.coords.lat != 0 ? (
					<TouchableHighlight style={css.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => general.gotoNavigationApp('walk', data.coords.lat, data.coords.lon) }>
						<View style={css.dl_dir_traveltype_container}>
							<Image style={css.dl_dir_icon} source={ require('../assets/img/icon_walk.png')} />
							<Text style={css.dl_dir_eta}>Walk</Text>
						</View>
					</TouchableHighlight>
				) : null }
			</View>
		);
	},

	// #6 - NEARBY CARD
	getCurrentPosition: function(type) {
		if (type === 'lat') {
			if (this.state.currentPosition) {
				return this.state.currentPosition.coords.latitude;
			} else {
				return null;
			}
		} else if (type === 'lon') {
			if (this.state.currentPosition) {
				return this.state.currentPosition.coords.longitude;
			} else {
				return null;
			}
		}
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

	gotoFeedbackForm: function() {
		this.props.navigator.push({ id: 'WebWrapper', component: WebWrapper, title: 'Feedback', webViewURL: AppSettings.FEEDBACK_URL });
	},

	gotoPrivacyPolicy: function() {
		this.props.navigator.push({ id: 'WebWrapper', component: WebWrapper, title: 'About', webViewURL: AppSettings.PRIVACY_POLICY_URL });
	},

	gotoScheduleDetail: function() {
		this.props.navigator.push({ id: 'ScheduleDetail', component: ScheduleDetail, title: 'Schedule' });
	},

	gotoDiningDetail: function(marketData) {
		this.props.navigator.push({ id: 'DiningDetail', component: DiningDetail, title: marketData.name, marketData: marketData });
	},
	gotoDiningList(diningData) {
		this.props.navigator.push({ id: 'DiningList', title: 'Dining', name: 'Dining', component: DiningList, data: diningData });
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

	// Is this even used??
	_setState: function(myKey, myVal) {
		var state = {};
		state[myKey] = myVal;
		this.setState(state);
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

	_handleRefresh: function() {
		this.props.do_timeout();
		this.refreshAllCards('auto');
		this.setState({refreshing: false});
	}
});

module.exports = Home;
