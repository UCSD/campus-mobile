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
//import SurveyCardContainer from './survey/SurveyCardContainer';
//import ScheduleCard from './schedule/ScheduleCard';

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
		let card;

		/*if (this.props.loggedIn) {
			activeCards.push(<ScheduleCard key={'schedule'} />);
		}
		activeCards.push(<SurveyCardContainer key={'survey'} />);*/

		for (let i = 0; i < this.props.cardOrder.length; ++i) {
			const key = this.props.cardOrder[i];

			if (this.props.cards[key].active) {
				switch (key) {
				case 'conference':
					card = <ConferenceCardContainer key={'conference'} />;
					break;
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
		cards: state.cards.cards,
		cardOrder: state.cards.cardOrder,
		locationPermission: state.location.permission,
		scene: state.routes.scene,
		lastScroll: state.home.lastScroll,
		loggedIn: state.user.isLoggedIn
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
