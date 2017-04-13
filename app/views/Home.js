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

		if (this._scrollview) {
			this._scrollview.scrollTo({ y: this.props.lastScroll, animated: false });
		}
	}

	componentDidUpdate(prevProps, prevState) {
		// Handle scroll when switching into Home View but it doesn't re-mount
		if (prevProps.scene.sceneKey !== 'Home' &&
			prevProps.scene.sceneKey !== 'tabbar' &&
			this.props.scene.sceneKey === 'Home') {
			if (this._scrollview) {
				this._scrollview.scrollTo({ y: this.props.lastScroll, animated: false });
			}
		}
	}

	handleScroll = (event) => {
		if (this.props.updateScroll) {
			this.props.updateScroll(event.nativeEvent.contentOffset.y);
		}
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
						<ScrollView
							ref={c => { this._scrollview = c; }}
							onScroll={this.handleScroll}
							scrollEventThrottle={69}
						>
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
		scene: state.routes.scene,
		lastScroll: state.home.lastScroll
	};
}

function mapDispatchtoProps(dispatch) {
	return {
		updateScroll: (scrollY) => {
			dispatch({ type: 'UPDATE_HOME_SCROLL', scrollY });
		}
	};
}

module.exports = connect(mapStateToProps, mapDispatchtoProps)(Home);
