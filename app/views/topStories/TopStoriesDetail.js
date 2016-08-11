'use strict';

import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	LinkingIOS,
	TouchableHighlight,
	Dimensions,
	Navigator,
} from 'react-native';
import NavigationBarWithRouteMapper from '../NavigationBarWithRouteMapper';

var css = require('../../styles/css');
var WebWrapper = require('../WebWrapper');

var windowSize = Dimensions.get('window');
var windowWidth = windowSize.width;

var logger = require('../../util/logger');
var general = require('../../util/general');

var TopStoriesDetail = React.createClass({

	getInitialState: function() {
		return {
			newsImgWidth: null,
			newsImgHeight: null
		}
	},

	componentWillMount: function() {

		logger.custom('View Loaded: News Detail');

		if (this.props.route.topStoriesData.image_lg) {
			Image.getSize(this.props.route.topStoriesData.image_lg, (width, height) => {
				this.setState({
					newsImgWidth: windowWidth,
					newsImgHeight: height * (windowWidth / width)
				});
			});
		}
	},

	render: function() {
		if (general.platformAndroid() || AppSettings.NAVIGATOR_ENABLED) {
			return (
				<NavigationBarWithRouteMapper
					route={this.props.route}
					renderScene={this.renderScene}
					navigator={this.props.navigator}
				/>
			);
		} else {
			return this.renderScene();
		}
	},

	renderScene: function() {

		var ts_date = new Date(this.props.route.topStoriesData['date']);

		// Year
		var ts_year = ts_date.getFullYear();

		// Month
		var ts_months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
		var ts_month = ts_date.getMonth();
		var ts_dayofmonth = ts_date.getDate();
		var ts_month = ts_months[ts_month];

		// Day
		var ts_days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
		var ts_day = ts_date.getDay();
		var ts_dayofweek = ts_days[ts_day];

		// HH:MM
		var ts_hours = ts_date.getHours();
		var ts_minutes = "0" + ts_date.getMinutes();
		var ts_seconds = "0" + ts_date.getSeconds();

		var ts_ampm = ts_hours >= 12 ? 'PM' : 'AM';
		ts_hours = ts_hours % 12;
		ts_hours = ts_hours ? ts_hours : 12;
		var ts_hhmm = ts_hours + ':' + ts_minutes.substr(-2) + ts_ampm;
		var ts_datestr = ts_month + ' ' + ts_dayofmonth + ', ' + ts_year;

		// Desc
		var topStoriesDesc = this.props.route.topStoriesData.description;
		topStoriesDesc = topStoriesDesc.replace(/^ /g, '');
		topStoriesDesc = topStoriesDesc.replace(/\?\?\?/g, '');

		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={css.scroll_default}>

					{this.state.newsImgWidth ? (
						<Image style={[css.eventdetail_image_tmp, { width: this.state.newsImgWidth, height: this.state.newsImgHeight }]} source={{ uri: this.props.route.topStoriesData.image_lg }} />
					) : null }

					<View style={css.news_detail_container}>
						<View style={css.eventdetail_top_right_container}>
							<Text style={css.eventdetail_eventname}>{this.props.route.topStoriesData.title}</Text>
							<Text style={css.eventdetail_eventdate}>{ts_datestr}</Text>
						</View>

						<Text style={css.eventdetail_eventdescription}>{topStoriesDesc}</Text>

						{this.props.route.topStoriesData.link ? (
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoWebView(this.props.route.topStoriesData.title, this.props.route.topStoriesData.link) }>
								<View style={css.eventdetail_readmore_container}>
									<Text style={css.eventdetail_readmore_text}>Read the full article</Text>
								</View>
							</TouchableHighlight>
						) : null }

					</View>

				</ScrollView>
			</View>
		);
	},

	openBrowserLink: function(linkURL) {
		LinkingIOS.openURL(linkURL);
	},

	gotoWebView: function(storyName, storyURL) {
		this.props.navigator.push({ component: WebWrapper, title: storyName, webViewURL: storyURL });
	},

});

module.exports = TopStoriesDetail;
