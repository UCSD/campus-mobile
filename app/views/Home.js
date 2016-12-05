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

	getInitialState() {
		return {
			initialLoad: true,
			scrollEnabled: true,
			cacheMap: false,
			refreshing:false,
			updatedGoogle: true,
		}
	},

	componentWillMount() {
		if (general.platformAndroid()) {
			this.updateGooglePlay();
			this.setState({cacheMap: true});
		}
	},

	componentDidMount() {
		logger.ga('View Loaded: Home');
	},

	updateGooglePlay() {
		GoogleAPIAvailability.checkGooglePlayServices((result) => {
			if(result === 'update') {
				this.setState({ updatedGoogle: false });
			}
		});
	},

	render() {
		logger.log('Home: render');
		return this.renderScene();
	},

	renderScene(route, navigator, index, navState) {
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

	getCards() {
		var cards = [];
		var cardCounter = 0;

		// Setup Cards
		if (this.props.cards['weather'].active) {
			cards.push(<WeatherCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'weather'} />);
		}
		if (this.props.cards['shuttle'].active) {
			cards.push(<ShuttleCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'shuttle'} />);
		}
		if (this.props.cards['dining'].active) {
			cards.push(<DiningCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'dining'} />);
		}
		if (this.props.cards['events'].active) {
			cards.push(<EventCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'events'} />);
		}
		if (this.props.cards['quicklinks'].active) {
			cards.push(<QuicklinksCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'quicklinks'} />);
		}
		if (this.props.cards['news'].active) {
			cards.push(<NewsCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'news'} />);
		}
		if (this.props.cards['map'].active) {
			cards.push(<SearchCard navigator={this.props.navigator} ref={(c) => this.cards ? this.cards.push(c) : this.cards = [c]} key={'map'} />);
		}
		return cards;
	},

	refreshAllCards(refreshType) {
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

	gotoFeedbackForm() {
		this.props.navigator.push({ id: 'FeedbackView', component: FeedbackView, title: 'Feedback' });
	},

	_handleRefresh() {
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
