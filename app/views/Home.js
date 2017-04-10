import React from 'react';
import {
	View,
	ScrollView,
} from 'react-native';

import { Actions } from 'react-native-router-flux';
import { connect } from 'react-redux';
import { MenuContext } from 'react-native-popup-menu';
import { checkGooglePlayServices } from 'react-native-google-api-availability-bridge';
import CookieManager from 'react-native-cookies';

import TopBannerView from './banner/TopBannerView';

// Cards
import WeatherCardContainer from './weather/WeatherCardContainer';
import ShuttleCardContainer from './shuttle/ShuttleCardContainer';
import EventCardContainer from './events/EventCardContainer';
import QuicklinksCardContainer from './quicklinks/QuicklinksCardContainer';
import NewsCardContainer from './news/NewsCardContainer';
import DiningCardContainer from './dining/DiningCardContainer';

import { platformAndroid } from '../util/general';

// App Settings / Util / CSS
const css = require('../styles/css');
const logger = require('../util/logger');

import getAPIToken, { invokeAPI } from '../services/ssoService';

class Home extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			updatedGoogle: true,
		};
	}

	componentWillMount() {
		if (platformAndroid()) {
			this.updateGooglePlay();
		}
	}

	componentDidMount() {
		logger.ga('View Loaded: Home');
		this._cards = [];

		// caching was caused by the server setting the session cookie.
		// iOS/Android handles cookies automatically so it was used with every fetch call
		// investigate side effects?
		// Should be fine if only called on logout?
		/*
		CookieManager.clearAll((err, res) => {
			console.log('cookies cleared!');
			console.log(err);
			console.log(res);

			CookieManager.get('https://wso2is-qa.ucsd.edu/ecptoken/token', (err2, res2) => {
				console.log(err2);
				console.log('cookieget: ' + JSON.stringify(res2));

				const username = 'student2';
				const password = 'qwertyuiop';
				getAPIToken(username, password).then((apiToken) => {
					console.log(JSON.stringify(apiToken));
					//invokeAPI(apiToken).then((result) => console.log(JSON.stringify(result)));
				});
			});
		});*/
	}

	_getCards = () => {
		const activeCards = [];
		// Setup Cards
		if (this.props.cards.weather.active) {
			activeCards.push(<WeatherCardContainer key={'weather'} />);
		}
		if (this.props.cards.shuttle.active) {
			activeCards.push(<ShuttleCardContainer key={'shuttle'} />);
		}
		if (this.props.cards.dining.active) {
			activeCards.push(<DiningCardContainer key={'dining'} />);
		}
		if (this.props.cards.events.active) {
			activeCards.push(<EventCardContainer key={'events'} />);
		}
		if (this.props.cards.quicklinks.active) {
			activeCards.push(<QuicklinksCardContainer key={'quicklinks'} />);
		}
		if (this.props.cards.news.active) {
			activeCards.push(<NewsCardContainer key={'news'} />);
		}
		return activeCards;
	}

	updateGooglePlay = () => {
		checkGooglePlayServices((result) => {
			if (result === 'update') {
				this.setState({ updatedGoogle: false });
			}
		});
	}

	render() {
		// Prevent home from re-rendering when not in home
		if (this.props.scene.sceneKey !== 'Home' && this.props.scene.sceneKey !== 'tabbar') {
			return null;
		} else {
			return (
				<MenuContext style={{ flex:1 }}>
					<View style={css.main_container}>
						<ScrollView>
							{/* SPECIAL TOP BANNER */}
							<TopBannerView />

							{/* LOAD CARDS */}
							{ this._getCards() }
						</ScrollView>
					</View>
				</MenuContext>
			);
		}
	}
}

function mapStateToProps(state, props) {
	return {
		cards: state.cards,
		locationPermission: state.location.permission,
		scene: state.routes.scene
	};
}

module.exports = connect(mapStateToProps)(Home);
