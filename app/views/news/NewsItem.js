import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import NewsDetail from './NewsDetail';

const css = require('../../styles/css');
const moment = require('moment');

const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export default class NewsItem extends React.Component {

	getStoryDescription(description, title) {
		let newsDescription = description.replace(/^ /g, '');
		if (newsDescription.length > 0) {
			if (title.length < 25) {
				newsDescription = newsDescription.substring(0,56).replace(/ $/,'') + '...';
			} else if (title.length < 50) {
				newsDescription = newsDescription.substring(0,28).replace(/ $/,'') + '...';
			} else {
				newsDescription = '';
			}
		}
		return newsDescription;
	}

	gotoNewsDetail(newsData) {
		this.props.navigator.push({ id: 'NewsDetail', name: 'News', title: 'News', component: NewsDetail, newsData });
	}

	render() {
		const data = this.props.data;
		const newsDate = moment(data.date).format('MMM Do, YYYY');
		const newsDescription = this.getStoryDescription(data.description, data.title);
		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoNewsDetail(data)}>
				<View style={css.events_list_row}>
					<View style={css.events_list_left_container}>
						<Text style={css.events_list_title}>{data.title}</Text>
						{newsDescription ? (
							<Text style={css.events_list_desc}>{newsDescription}</Text>
						) : null }
						<Text style={css.events_list_postdate}>{newsDate}</Text>
					</View>

					{data.image ? (
						<Image style={css.news_list_image} source={{ uri: data.image }} />
					) : (
						<Image style={css.news_list_image} source={require('../../assets/img/MobileEvents_blank.jpg')} />
					)}

				</View>
			</TouchableHighlight>
		);
	}
}
