'use strict';

import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	Linking,
	TouchableHighlight,
	Dimensions,
} from 'react-native';
import NavigationBarWithRouteMapper from '../NavigationBarWithRouteMapper';

var WebWrapper = require('../WebWrapper');

var windowSize = Dimensions.get('window');
var windowWidth = windowSize.width;

var AppSettings = require('../../AppSettings');
var css = require('../../styles/css');
var logger = require('../../util/logger');
var general = require('../../util/general');

var NewsDetail = React.createClass({

	getInitialState: function() {
		return {
			newsImgWidth: null,
			newsImgHeight: null,
			newsImageURL: null,
		}
	},

	componentWillMount: function() {
		logger.ga('View Loaded: News Detail');

		var imageURL = (this.props.route.newsData.image_lg) ? this.props.route.newsData.image_lg : this.props.route.newsData.image;
		imageURL = imageURL.replace(/-thumb/g,'');

		if (imageURL) {
			Image.getSize(
				imageURL,
				(width, height) => {
					this.setState({
						newsImageURL: imageURL,
						newsImgWidth: windowWidth,
						newsImgHeight: Math.round(height * (windowWidth / width))
					});
				},
				(error) => { logger.log('ERR: componentWillMount: ' + error) }
			);
		}
	},

	componentDidMount: function() {
		logger.ga('View Loaded: News Detail: ' + this.props.route.newsData.title );
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {

		var ts_date = new Date(this.props.route.newsData['date']);

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
		var newsDesc = this.props.route.newsData.description;
		newsDesc = newsDesc.replace(/^ /g, '');
		newsDesc = newsDesc.replace(/\?\?\?/g, '');

		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={css.scroll_default}>

					{this.state.newsImageURL ? (
						<Image style={{ width: this.state.newsImgWidth, height: this.state.newsImgHeight }} source={{ uri: this.state.newsImageURL }} />
					) : null }

					<View style={css.news_detail_container}>
						<View style={css.eventdetail_top_right_container}>
							<Text style={css.eventdetail_eventname}>{this.props.route.newsData.title}</Text>
							<Text style={css.eventdetail_eventdate}>{ts_datestr}</Text>
						</View>

						<Text style={css.eventdetail_eventdescription}>{newsDesc}</Text>

						{this.props.route.newsData.link ? (
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoWebView(this.props.route.newsData.title, this.props.route.newsData.link) }>
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
		Linking.openURL(linkURL);
	},

	gotoWebView: function(storyName, storyURL) {
		//this.props.navigator.push({ id: 'WebWrapper', name: 'WebWrapper', title: 'News', component: WebWrapper, webViewURL: storyURL });
		Linking.canOpenURL(storyURL).then(supported => {
		if (!supported) {
			logger.log('Can\'t handle url: ' + storyURL);
		} else {
			return Linking.openURL(storyURL);
		}
		}).catch(err => console.error('An error with opening NewsDetail occurred', err));
	},

});

module.exports = NewsDetail;
