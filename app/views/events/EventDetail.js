import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	Linking,
	TouchableHighlight,
	Dimensions
} from 'react-native';

const windowSize = Dimensions.get('window');
const windowWidth = windowSize.width;

const css = require('../../styles/css');
const logger = require('../../util/logger');
const general = require('../../util/general');
const moment = require('moment');

const EventDetail = React.createClass({

	getInitialState() {
		return {
			newsImgWidth: null,
			newsImgHeight: null,
			eventImageURL: null,
		};
	},

	componentWillMount() {
		const imageURL = this.props.route.eventData.imagehq;

		if (imageURL) {
			Image.getSize(
				imageURL,
				(width, height) => {
					this.setState({
						eventImageURL: imageURL,
						newsImgWidth: windowWidth,
						newsImgHeight: Math.round(height * (windowWidth / width))
					});
				},
				(error) => { logger.log('ERR: componentWillMount: ' + error); }
			);
		}
	},

	componentDidMount() {
		logger.ga('View Loaded: Event Detail: ' + this.props.route.eventData.title);
	},

	openBrowserLink(linkURL) {
		Linking.openURL(linkURL);
	},

	gotoWebView(eventName, eventURL) {
		// this.props.navigator.push({ id: 'WebWrapper', name: 'WebWrapper', title: eventName, component: WebWrapper, webViewURL: eventURL });
		Linking.canOpenURL(eventURL).then(supported => {
			if (!supported) {
				logger.log('Can\'t handle url: ' + eventURL);
			} else {
				return Linking.openURL(eventURL);
			}
		}).catch(err => logger.log('An error with opening EventDetail occurred', err));
	},

	renderScene() {
		const data = this.props.route.eventData;
		const eventTitleStr = data.title;// EventTitle.replace('&amp;','&');
		const eventDescriptionStr = data.description;// EventDescription.replace('&amp;','&').trim();
		const eventDateStr = moment(data.eventdate).format("MMM Do") + ', ' + general.militaryToAMPM(data.starttime) + ' - ' + general.militaryToAMPM(data.endtime);

		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={css.scroll_default}>

					{this.state.eventImageURL ? (
						<Image style={{ width: this.state.newsImgWidth, height: this.state.newsImgHeight }} source={{ uri: this.state.eventImageURL }} />
					) : null }

					<View style={css.news_detail_container}>
						<View style={css.eventdetail_top_right_container}>
							<Text style={css.eventdetail_eventname}>{eventTitleStr}</Text>
							<Text style={css.eventdetail_eventlocation}>{data.location}</Text>
							<Text style={css.eventdetail_eventdate}>{eventDateStr}</Text>
						</View>

						<Text style={css.eventdetail_eventdescription}>{eventDescriptionStr}</Text>

						{this.props.route.eventData.contact_info ? (
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.openBrowserLink('mailto:' + data.EventContact)}>
								<View style={css.eventdetail_readmore_container}>
									<Text style={css.eventdetail_readmore_text}>Email: {data.contact_info}</Text>
								</View>
							</TouchableHighlight>
						) : null }

					</View>
				</ScrollView>
			</View>
		);
	},

	render() {
		return this.renderScene();
	},
});

module.exports = EventDetail;
