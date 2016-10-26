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
} from 'react-native';

import TopBannerView from './banner/TopBannerView';
import WelcomeModal from './WelcomeModal';
import NavigationBarWithRouteMapper from './NavigationBarWithRouteMapper';
import FeedbackView from './FeedbackView';

// Cards
import EventCard from './events/EventCard'
import NewsCard from './news/NewsCard';
import WeatherCard from './weather/WeatherCard';
import ShuttleCard from './shuttle/ShuttleCard';
import NearbyCard from './nearby/NearbyCard';

import YesNoCard from './survey/YesNoCard';
import MultipleChoiceCard from './survey/MultipleChoiceCard';
import IntervalCard from './survey/IntervalCard';
import TextInputCard from './survey/TextInputCard';

// Node Modules
import TimerMixin from 'react-timer-mixin';
const Permissions = require('react-native-permissions');
const GoogleAPIAvailability = require('react-native-google-api-availability-bridge');

// App Settings / Util / CSS
const AppSettings = require('../AppSettings');
const css = require('../styles/css');
const general = require('../util/general');
const logger = require('../util/logger');
const shuttle = require('../util/shuttle');

// Views
const DiningDetail = require('./dining/DiningDetail');
const DiningList = require('./dining/DiningList');

var Home = React.createClass({

	mixins: [TimerMixin],
	permissionUpdateInterval: 1 * 65 * 1000,
	diningDefaultResults: 4,
	copyrightYear: new Date().getFullYear(),
	geolocationWatchID: null,

	getInitialState: function() {
		return {
			initialLoad: true,
			scrollEnabled: true,
			diningDataLoaded: false,
			diningRenderAllRows: false,
			locationPermission: 'undetermined',
			currentPosition: null,
			cacheMap: false,
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
	},

	componentWillUnmount: function() {
		// Update unmount function with ability to clear all other timers (setTimeout/setInterval)
		navigator.geolocation.clearWatch(this.geolocationWatchID);
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
			this.getLocationPermission();
		});
	},

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

					{/* SHUTTLE_CARD & EVENTS CARD & NEWS CARD & WEATHER CARD */}
					{ this.getCards() }

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
									<View style={[css.card_row_center, css.card_loader]}>
										<ActivityIndicator size="large" />
									</View>
								)}
							</View>
						</View>
					) : null }
					
					{/* NEARBY CARD */}
					{ this.getNearbyCard() }

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

	getCards: function() {
		var cards = [];
		var cardCounter = 0;
		// Setup Cards
		// Keys need to be unique, there's probably a better solution, but this works for now
		if (AppSettings.WEATHER_CARD_ENABLED) {
			cards.push(<WeatherCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key='weather' />);
		}
		if (AppSettings.SHUTTLE_CARD_ENABLED) {
			cards.push(<ShuttleCard navigator={this.props.navigator} location={this.state.currentPosition} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key='shuttle' />);
		}
		if (AppSettings.EVENTS_CARD_ENABLED) {
			cards.push(<EventCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key='events' />);
		}
		if (AppSettings.NEWS_CARD_ENABLED) {
			cards.push(<NewsCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key='news' />);
		}
		return cards;
	},

	// Replace with dining card breakout in v2.4
	getNearbyCard: function() {
		var cards = [];
		var cardCounter = 10;
		// Setup Cards
		// Keys need to be unique, there's probably a better solution, but this works for now
		if (AppSettings.NEARBY_CARD_ENABLED) {
			cards.push(<NearbyCard navigator={this.props.navigator} getCurrentPosition={(latlon) => this.getCurrentPosition(latlon)} updatedGoogle={this.state.updatedGoogle} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]}  key={'nearby'}/>);
		}
		return cards;
	},

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

				// Calc distance from dining locations
				for (var i = 0; responseData.length > i; i++) {
					var distance = shuttle.getDistance(this.getCurrentPosition('lat'), this.getCurrentPosition('lon'), responseData[i].coords.lat, responseData[i].coords.lon);
					if (distance) {
						responseData[i].distance = distance;
					} else {
						responseData[i].distance = 100000000;
					}

					responseData[i].distanceMiles = general.convertMetersToMiles(distance);
					responseData[i].distanceMilesStr = general.getDistanceMilesStr(responseData[i].distanceMiles);
				}

				// Sort dining locations by distance
				responseData.sort(this.sortNearbyMarkers);
				var responseDataPartial = responseData.slice(0, this.diningDefaultResults);

				var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

				this.setState({
					diningData: responseData,
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
		var dayOfWeek = general.getTimestamp('ddd').toLowerCase();

		return (
			<View style={css.dc_locations_row}>
				<TouchableHighlight style={css.dc_locations_row_left} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningDetail(data) }>
					<View>
						<Text style={css.dc_locations_title}>{data.name}</Text>
						<Text style={css.dc_locations_hours}>{data.regularHours}</Text>
					</View>
				</TouchableHighlight>

				{data.coords.lat != 0 ? (
					<TouchableHighlight style={css.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => general.gotoNavigationApp('walk', data.coords.lat, data.coords.lon) }>
						<View style={css.dl_dir_traveltype_container}>
							<Image style={css.dl_dir_icon} source={ require('../assets/img/icon_walk.png')} />
							<Text style={css.dl_dir_eta}>{data.distanceMilesStr}</Text>
						</View>
					</TouchableHighlight>
				) : null }
			</View>
		);
	},

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
		this.props.navigator.push({ id: 'FeedbackView', component: FeedbackView, title: 'Feedback' });
	},

	gotoScheduleDetail: function() {
		this.props.navigator.push({ id: 'ScheduleDetail', component: ScheduleDetail, title: 'Schedule' });
	},

	gotoDiningDetail: function(marketData) {
		this.props.navigator.push({ id: 'DiningDetail', component: DiningDetail, title: 'Dining', marketData: marketData });
	},

	gotoDiningList(diningData) {
		this.props.navigator.push({ id: 'DiningList', title: 'Dining', name: 'Dining', component: DiningList, data: diningData });
	},

	_handleRefresh: function() {
		this.props.do_timeout();
		this.refreshAllCards('auto');
		this.setState({refreshing: false});
	}
});

module.exports = Home;
