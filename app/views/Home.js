import React from 'react';
import {
	View,
	ScrollView,
} from 'react-native';

import { connect } from 'react-redux';
import { MenuContext } from 'react-native-popup-menu';
import { checkGooglePlayServices } from 'react-native-google-api-availability-bridge';

import TopBannerView from './banner/TopBannerView';

// Cards
import WeatherCardContainer from './weather/WeatherCardContainer';
import ShuttleCardContainer from './shuttle/ShuttleCardContainer';
import EventCardContainer from './events/EventCardContainer';
import QuicklinksCard from './quicklinks/QuicklinksCard';
import NewsCardContainer from './news/NewsCardContainer';
import DiningCardContainer from './dining/DiningCardContainer';

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
			activeCards.push(<QuicklinksCard key={'quicklinks'} />);
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
		return (
			<MenuContext style={{ flex:1 }}>
				<View style={css.main_container}>
					<ScrollView contentContainerStyle={css.scroll_main}>
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
		cards: state.cards,
		locationPermission: state.location.permission
	};
}

module.exports = connect(mapStateToProps)(Home);
