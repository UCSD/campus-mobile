'use strict'

import React from 'react'
import {
	View,
	TouchableHighlight,
	Image,
	Text,
	Modal
} from 'react-native';

import BannerView from './BannerView';
import WelcomeWeekView from '../welcomeWeek/WelcomeWeekView';
import TimerMixin from 'react-timer-mixin';

var css =             require('../../styles/css');
var general = 			  require('../../util/general');
var AppSettings = 		require('../../AppSettings');

// Manages the top 'hero' banner & decides what if anything to show
// Currently decides based on static dates but an API would be great for breaking info

/* Re-enable when pull#12 comes in for react-timer-mixin
export default class TopBannerView extends Timer(React.Component) {
	constructor(props) {
		super(props);
		this.state = {
			site: {
				title: 'Welcome Week',
				url: AppSettings.WELCOME_WEEK_URL
			},
			bannerImage: require('../../assets/img/welcome_week.jpg'),
		};
	}

	render() {
		let shouldShowWelcomeBanner = false;
		// Check welcome week date range - Activate from Aug 1 to Sep 24
		var currentYear = general.getTimestamp('yyyy');
		var currentMonth = general.getTimestamp('m');
		var currentDay = general.getTimestamp('d');
		if ((currentYear == 2016) && ((currentMonth == 8) || (currentMonth == 9 && currentDay <= 24))) {
		shouldShowWelcomeBanner = true;
	}

	if (!shouldShowWelcomeBanner){ // show nothing if it isn't the correct time
		return null;
	}

		return(
			/*
			<BannerView
			navigator={this.props.navigator}
			site={this.state.site}
			bannerImage={this.state.bannerImage} />
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this._handleOnPress()}>
			<Image style={[css.card_plain, css.card_special_events]} source={ this.state.bannerImage } />
			</TouchableHighlight>
		);
	}

	_handleOnPress() {
		// Always use TimerMixin with requestAnimationFrame, setTimeout and
		// setInterval
		this.requestAnimationFrame(() => {
			this.gotoWelcomeWeekView();
		});
	}

	gotoWelcomeWeekView() {
		this.props.navigator.push({ id: 'WelcomeWeekView', title: 'Welcome Week', name: 'Welcome Week', component: WelcomeWeekView });
	}
}
*/
var TopBannerView = React.createClass({
	mixins: [TimerMixin],
	getInitialState() {
		return {
			site: {
				title: 'Welcome Week',
				url: AppSettings.WELCOME_WEEK_URL
			},
			bannerImage: require('../../assets/img/welcome_week.jpg'),
		};
	},

	render() {
		let shouldShowWelcomeBanner = false;
		// Check welcome week date range - Activate from Aug 1 to Sep 24
		var currentYear = general.getTimestamp('yyyy');
		var currentMonth = general.getTimestamp('m');
		var currentDay = general.getTimestamp('d');
		if ((currentYear == 2016) && ((currentMonth == 8) || (currentMonth == 9 && currentDay <= 24))) {
			shouldShowWelcomeBanner = true;
		}

		if (!shouldShowWelcomeBanner){ // show nothing if it isn't the correct time
			return null;
		}

		return(
			/*
			<BannerView
			navigator={this.props.navigator}
			site={this.state.site}
			bannerImage={this.state.bannerImage} />*/
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this._handleOnPress()}>
			<Image style={[css.card_plain, css.card_special_events]} source={ this.state.bannerImage } />
			</TouchableHighlight>
		);
	},

	_handleOnPress() {
		// Always use TimerMixin with requestAnimationFrame, setTimeout and
		// setInterval
		this.requestAnimationFrame(() => {
			this.gotoWelcomeWeekView();
		});
	},

	gotoWelcomeWeekView() {
		this.props.navigator.push({ id: 'WelcomeWeekView', title: 'Welcome Week', name: 'Welcome Week', component: WelcomeWeekView });
	}
});
module.exports = TopBannerView;