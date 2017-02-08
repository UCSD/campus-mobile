import React from 'react';
import {
	View,
	ScrollView,
} from 'react-native';

import { connect } from 'react-redux';
import { MenuContext } from 'react-native-popup-menu';
import { checkGooglePlayServices } from 'react-native-google-api-availability-bridge';

import TopBannerView from './banner/TopBannerView';
import WelcomeModal from './WelcomeModal';

// Cards
import WeatherCardContainer from './weather/WeatherCardContainer';
import ShuttleCardContainer from './shuttle/ShuttleCardContainer';
import EventCard from './events/EventCard';
import QuicklinksCard from './quicklinks/QuicklinksCard';
import NewsCard from './news/NewsCard';
import DiningCard from './dining/DiningCard';

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
			activeCards.push(<DiningCard key={'dining'} />);
		}
		if (this.props.cards.events.active) {
			activeCards.push(<EventCard key={'events'} />);
		}
		if (this.props.cards.quicklinks.active) {
			activeCards.push(<QuicklinksCard key={'quicklinks'} />);
		}
		if (this.props.cards.news.active) {
			activeCards.push(<NewsCard key={'news'} />);
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
					<ScrollView
						contentContainerStyle={css.scroll_main}
					>
						{/* WELCOME MODAL */}
						<WelcomeModal />

						{/* SPECIAL TOP BANNER */}
						<TopBannerView />

						{/* LOAD PRIMARY CARDS */}
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
