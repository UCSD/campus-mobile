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

		storyDescriptionStr = storyDescriptionStr.substring(0,115).replace(/ $/,'') + '...';

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
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoNewsDetail(this.props.data)}>
				<View style={css.card_main}>
					<View style={css.events_card_title_container}>
						<Text style={css.events_card_title}>{storyTitle}</Text>
					</View>
					<View style={css.events_card_container}>
						<View style={css.events_card_left_container}>
							{storyDescriptionStr ? (<Text style={css.events_card_desc}>{storyDescriptionStr}</Text>) : null }
							<Text style={css.events_card_postdate}>{storyDateMonthStr} {storyDateDay}</Text>
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
