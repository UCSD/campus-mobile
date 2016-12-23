import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import NewsDetail from './NewsDetail';
import { Actions } from 'react-native-router-flux';

const css = require('../../styles/css');
const moment = require('moment');

const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export default class NewsItem extends React.Component {

	getStoryDescription(description, title) {
		let storyDescriptionStr = description.replace(/^ /g, '');
		storyDescriptionStr = storyDescriptionStr.substring(0,115).replace(/ $/,'') + '...';
		return storyDescriptionStr;
	}

	gotoNewsDetail(newsData) {
		Actions.NewsDetail({ newsData });
	}

	render() {
		const data = this.props.data;
		const newsDate = moment(data.date).format('MMM Do, YYYY');
		const storyDescription = this.getStoryDescription(data.description, data.title);

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoNewsDetail(this.props.data)}>
				<View style={css.card_main}>
					<View style={css.events_card_title_container}>
						<Text style={css.events_card_title}>{data.title}</Text>
					</View>
					<View style={css.events_card_container}>
						<View style={css.events_card_left_container}>
							{storyDescription ? (<Text style={css.events_card_desc}>{storyDescription}</Text>) : null }
							<Text style={css.events_card_postdate}>{newsDate}</Text>
						</View>
						{data.image ? (
							<Image style={css.news_card_image} source={{ uri: data.image }} />
						) : (
							<Image style={css.news_card_image} source={require('../../assets/img/MobileEvents_blank.jpg')} />
						)}
					</View>
				</View>
			</TouchableHighlight>
		);
	}
}
