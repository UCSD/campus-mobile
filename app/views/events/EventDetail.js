'use strict';

import React from 'react';
import {
    Platform,
	View,
	Text,
	ScrollView,
	Image,
	LinkingIOS,
	TouchableHighlight,
	Dimensions
} from 'react-native';


var css = require('../../styles/css');
var logger = require('../../util/logger');
var WebWrapper = require('../WebWrapper');

var windowSize = Dimensions.get('window');
var windowWidth = windowSize.width;

var EventDetail = React.createClass({

	getInitialState: function() {
		return {
			newsImgWidth: null,
			newsImgHeight: null
		}
	},

	componentWillMount: function() {
		logger.custom('View Loaded: Event Detail');

		if (this.props.route.eventData.EventImageLg) {
			Image.getSize(this.props.route.eventData.EventImageLg, (width, height) => {
				this.setState({
					newsImgWidth: windowWidth,
					newsImgHeight: height * (windowWidth / width)
				});
			});
		}
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {

		var eventTitleStr = this.props.route.eventData.EventTitle.replace('&amp;','&');
		var eventDescriptionStr = this.props.route.eventData.EventDescription.replace('&amp;','&').trim();
		var eventDateStr = '';
		var eventDateArray = this.props.route.eventData.EventDate;

		if (eventDateArray) {
			for (var i = 0; eventDateArray.length > i; i++) {
				eventDateStr += eventDateArray[i].replace(/AM/g,'am').replace(/PM/g,'pm');
				if (eventDateArray.length !== i + 1) {
					 eventDateStr += '\n';
				}
			}
		} else {
			eventDateStr = 'Ongoing Event';
		}

		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={css.scroll_default}>

					{this.state.newsImgWidth ? (
						<Image style={{ width: this.state.newsImgWidth, height: this.state.newsImgHeight }} source={{ uri: this.props.route.eventData.EventImageLg }} />
					) : null }

					<View style={css.news_detail_container}>
						<View style={css.eventdetail_top_right_container}>
							<Text style={css.eventdetail_eventname}>{eventTitleStr}</Text>
							<Text style={css.eventdetail_eventlocation}>{this.props.route.eventData.EventLocation}</Text>
							<Text style={css.eventdetail_eventdate}>{eventDateStr}</Text>
						</View>

						<Text style={css.eventdetail_eventdescription}>{eventDescriptionStr}</Text>

						{this.props.route.eventData.EventContact ? (
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.openBrowserLink('mailto:' + this.props.route.eventData.EventContact) }>
								<View style={css.eventdetail_readmore_container}>
									<Text style={css.eventdetail_readmore_text}>Email: {this.props.route.eventData.EventContact}</Text>
								</View>
							</TouchableHighlight>
						) : null }

						{this.props.route.eventData.EventURL ? (
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoWebView(eventTitleStr, this.props.route.eventData.EventURL) }>
								<View style={css.eventdetail_readmore_container}>
									<Text style={css.eventdetail_readmore_text}>Visit the official site</Text>
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

	gotoWebView: function(eventName, eventURL) {
		this.props.navigator.push({ component: WebWrapper, title: eventName, webViewURL: eventURL });
	},

});

module.exports = EventDetail;
