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
import { connect } from 'react-redux';

import TopBannerView from './banner/TopBannerView';
import WelcomeModal from './WelcomeModal';
import NavigationBarWithRouteMapper from './NavigationBarWithRouteMapper';
import FeedbackView from './FeedbackView';

// Cards
import WeatherCard from './weather/WeatherCard';
import ShuttleCard from './shuttle/ShuttleCard';
import EventCard from './events/EventCard'
import QuicklinksCard from './quicklinks/QuicklinksCard'
import NewsCard from './news/NewsCard';
import DiningCard from './dining/DiningCard';
import SearchCard from './mapsearch/SearchCard';

import YesNoCard from './survey/YesNoCard';
import MultipleChoiceCard from './survey/MultipleChoiceCard';
import IntervalCard from './survey/IntervalCard';
import TextInputCard from './survey/TextInputCard';

// actions
import { updateLocation } from '../actions/location';

// Node Modules
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

	copyrightYear: new Date().getFullYear(),

	getInitialState: function() {
		return {
			initialLoad: true,
			scrollEnabled: true,
			cacheMap: false,
			refreshing:false,
			updatedGoogle: true,
		}
	},

	componentWillMount: function() {
		if (general.platformAndroid()) {
			this.updateGooglePlay();
			this.setState({cacheMap: true});
		}
	},

	componentDidMount: function() {
		logger.ga('View Loaded: Home');
	},

	updateGooglePlay: function() {
		GoogleAPIAvailability.checkGooglePlayServices((result) => {
			if(result === 'update') {
				this.setState({updatedGoogle: false})
			}
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
					<RefreshControl refreshing={this.state.refreshing} onRefresh={this._handleRefresh} tintColor='#CCC' title='' />
				}>

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

		// Setup Cards
		if (this.props.cards['Weather']) {
			cards.push(<WeatherCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'Weather'} />);
		}
		if (this.props.cards['Shuttle']) {
			cards.push(<ShuttleCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'Shuttle'} />);
		}
		if (this.props.cards['Dining']) {
			cards.push(<DiningCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'Dining'} />);
		}
		if (this.props.cards['Events']) {
			cards.push(<EventCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'Events'} />);
		}
		if (this.props.cards['Quick Links']) {
			cards.push(<QuicklinksCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'Quick Links'} />);
		}		
		if (this.props.cards['News']) {
			cards.push(<NewsCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'News'} />);
		}
		if (this.props.cards['Map']) {
			cards.push(<SearchCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'Map'} />);
		}
		return cards;
	},

	refreshAllCards: function(refreshType) {
		if (!refreshType) {
			refreshType = 'manual';
		}

		// Refresh location
		if (this.props.locationPermission === 'authorized') {
			this.props.dispatch(updateLocation());
		}

		// Refresh cards
		if (this.refs.cards) {
			this.refs.cards.forEach(c => c.refresh());
		}
	},

	gotoFeedbackForm: function() {
		this.props.navigator.push({ id: 'FeedbackView', component: FeedbackView, title: 'Feedback' });
	},

	_handleRefresh: function() {
		this.refreshAllCards('auto');
		this.setState({refreshing: false});
	}
});

function mapStateToProps(state, props) {
	return {
		cards: state.cards,
		locationPermission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(Home);
