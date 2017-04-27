import React from 'react';
import {
	View,
	ScrollView,
} from 'react-native';

import { Actions } from 'react-native-router-flux';
import { connect } from 'react-redux';
import { MenuContext } from 'react-native-popup-menu';
import { checkGooglePlayServices } from 'react-native-google-api-availability-bridge';

import TopBannerView from './banner/TopBannerView';

// Cards
import WeatherCardContainer from './weather/WeatherCardContainer';
import ShuttleCardContainer from './shuttle/ShuttleCardContainer';
import EventCardContainer from './events/EventCardContainer';
import QuicklinksCardContainer from './quicklinks/QuicklinksCardContainer';
import NewsCardContainer from './news/NewsCardContainer';
import DiningCardContainer from './dining/DiningCardContainer';
import ConferenceCardContainer from './conference/ConferenceCardContainer';

import { platformAndroid } from '../util/general';

// App Settings / Util / CSS
const css = require('../styles/css');
const logger = require('../util/logger');

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
	}

	_getCards = () => {
		const activeCards = [];
		let card;

		activeCards.push(<ConferenceCardContainer key={'conference'} />);

		for (let i = 0; i < this.props.cardOrder.length; ++i) {
			const key = this.props.cardOrder[i];

			if (this.props.cards[key].active) {
				switch (key) {
				case 'weather':
					card = (<WeatherCardContainer key={'weather'} />);
					break;
				case 'shuttle':
					card = (<ShuttleCardContainer key={'shuttle'} />);
					break;
				case 'dining':
					card = (<DiningCardContainer key={'dining'} />);
					break;
				case 'events':
					card = (<EventCardContainer key={'events'} />);
					break;
				case 'quicklinks':
					card = (<QuicklinksCardContainer key={'quicklinks'} />);
					break;
				case 'news':
					card = (<NewsCardContainer key={'news'} />);
					break;
				}
				activeCards.push(card);
			}
		}
		/*
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
		*/
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

function mapStateToProps(state, props) {
	return {
		cards: state.cards.cards,
		cardOrder: state.cards.cardOrder,
		locationPermission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(Home);
