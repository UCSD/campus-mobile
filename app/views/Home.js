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
import WeatherCard from './weather/WeatherCard';
import ShuttleCard from './shuttle/ShuttleCard';
import EventCard from './events/EventCard'
import NewsCard from './news/NewsCard';
import DiningCard from './dining/DiningCard';
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
	//diningDefaultResults: 4,
	copyrightYear: new Date().getFullYear(),
	geolocationWatchID: null,

	getInitialState: function() {
		return {
			initialLoad: true,
			scrollEnabled: true,
			//diningDataLoaded: false,
			//diningRenderAllRows: false,
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
					/>}>
					
					{/* WELCOME MODAL */}
					<WelcomeModal />

					{/* SPECIAL TOP BANNER */}
					<TopBannerView navigator={this.props.navigator}/>

					{/* LOAD PRIMARY CARDS */}
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

	getCards: function() {
		var cards = [];
		var cardCounter = 0;

		// Setup Active Cards
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
		if (AppSettings.DINING_CARD_ENABLED) {
			cards.push(<DiningCard navigator={this.props.navigator} location={this.state.currentPosition} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'dining'} />);
		}
		if (AppSettings.NEARBY_CARD_ENABLED) {
			cards.push(<NearbyCard navigator={this.props.navigator} getCurrentPosition={(latlon) => this.getCurrentPosition(latlon)} updatedGoogle={this.state.updatedGoogle} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'nearby'} />);
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

		// Refresh cards
		if (this.refs.cards) {
			this.refs.cards.forEach(c => c.refresh());
		}
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

	_handleRefresh: function() {
		this.props.do_timeout();
		this.refreshAllCards('auto');
		this.setState({refreshing: false});
	}
});

module.exports = Home;
