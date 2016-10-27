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

const windowSize = Dimensions.get('window');
const windowWidth = windowSize.width;

const css = require('../../styles/css');
const logger = require('../../util/logger');

const NewsDetail = React.createClass({

	getInitialState() {
		return {
			newsImgWidth: null,
			newsImgHeight: null,
			newsImageURL: null,
		};
	},

	componentWillMount() {
		logger.ga('View Loaded: News Detail');

		let imageURL = (this.props.route.newsData.image_lg) ? this.props.route.newsData.image_lg : this.props.route.newsData.image;
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
				(error) => { logger.log('ERR: componentWillMount: ' + error); }
			);
		}
	},

	componentDidMount() {
		logger.ga('View Loaded: News Detail: ' + this.props.route.newsData.title );
	},

	openBrowserLink(linkURL) {
		Linking.openURL(linkURL);
	},

	gotoWebView(storyName, storyURL) {
		// this.props.navigator.push({ id: 'WebWrapper', name: 'WebWrapper', title: 'News', component: WebWrapper, webViewURL: storyURL });
		Linking.canOpenURL(storyURL).then(supported => {
			if (!supported) {
				logger.log('Can\'t handle url: ' + storyURL);
			} else {
				return Linking.openURL(storyURL);
			}
		}).catch(err => logger.log('An error with opening NewsDetail occurred', err));
	},

	renderScene() {
		const ts_date = new Date(this.props.route.newsData.date);

		// TODO: really this whole thing should be replace with momentjs

		// Year
		const ts_year = ts_date.getFullYear();

		// Month
		const ts_months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
		let ts_month = ts_date.getMonth();
		const ts_dayofmonth = ts_date.getDate();
		ts_month = ts_months[ts_month];

		const ts_datestr = ts_month + ' ' + ts_dayofmonth + ', ' + ts_year;

		// Desc
		let newsDesc = this.props.route.newsData.description;
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
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoWebView(this.props.route.newsData.title, this.props.route.newsData.link)}>
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

	render() {
		return this.renderScene();
	},

});

module.exports = NewsDetail;
