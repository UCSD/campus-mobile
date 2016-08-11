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

var css =             require('../../styles/css');
var general = 			  require('../../util/general');
var AppSettings = 		require('../../AppSettings');

// Manages the top 'hero' banner & decides what if anything to show
// Currently decides based on static dates but an API would be great for breaking info
export default class TopBannerView extends React.Component {
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
		console.log("TopBanner Props: " + this.props.navigator);
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
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoWelcomeWeekView()}>
			<Image style={[css.card_plain, css.card_special_events]} source={ this.state.bannerImage } />
			</TouchableHighlight>
		);
	}

	gotoWelcomeWeekView() {
		this.props.navigator.push({ id: 'WelcomeWeekView', component: WelcomeWeekView, title: 'Welcome Week'});
	}
}
