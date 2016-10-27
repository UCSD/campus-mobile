import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import NewsDetail from './NewsDetail';

const css = require('../../styles/css');

const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export default class NewsItem extends React.Component {

	getStoryDescription(description, title) {
		let storyDescriptionStr = description.replace(/^ /g, '');

		if (storyDescriptionStr.length > 0) {
			if (title.length < 25) {
				storyDescriptionStr = storyDescriptionStr.substring(0,56).replace(/ $/,'') + '...';
			} else if (title.length < 50) {
				storyDescriptionStr = storyDescriptionStr.substring(0,28).replace(/ $/,'') + '...';
			} else {
				storyDescriptionStr = '';
			}
		}

		return storyDescriptionStr;
	}

	gotoNewsDetail(newsData) {
		this.props.navigator.push({ id: 'NewsDetail', name: 'News', title: 'News', component: NewsDetail, newsData });
	}

	render() {
		const data = this.props.data;

		const storyDate = data.date;
		let storyDateMonth = storyDate.substring(5,7);
		let storyDateDay = storyDate.substring(8,10);

		if (storyDateMonth.substring(0,1) === '0') {
			storyDateMonth = storyDateMonth.substring(1,2);
		}
		if (storyDateDay.substring(0,1) === '0') {
			storyDateDay = storyDateDay.substring(1,2);
		}

		const storyDateMonthStr = monthNames[storyDateMonth - 1];

		const storyTitle = data.title;

		const storyDescriptionStr = this.getStoryDescription(data.description, data.title);
		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoNewsDetail(data)}>
				<View style={css.events_list_row}>
					<View style={css.events_list_left_container}>
						<Text style={css.events_list_title}>{storyTitle}</Text>
						{storyDescriptionStr ? (
							<Text style={css.events_list_desc}>{storyDescriptionStr}</Text>
						) : null }
						<Text style={css.events_list_postdate}>{storyDateMonthStr} {storyDateDay}</Text>
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
