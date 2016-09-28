'use strict'

import React from 'react'
import {
	StyleSheet,
	View,
	Text,
	Navigator,
	TouchableHighlight,
	Image,
	Linking
} from 'react-native';

import NewsDetail from './NewsDetail'
import Card from '../card/Card'

var css = require('../../styles/css');

const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export default class NewsItem extends React.Component {

	gotoNewsDetail(newsData) {
  		this.props.navigator.push({ id: 'NewsDetail', name: 'News', title: 'News', component: NewsDetail, newsData: newsData });
	}

	gotoWebView(storyName, storyURL) {
		//this.props.navigator.push({ id: 'WebWrapper', name: 'WebWrapper', title: 'News', component: WebWrapper, webViewURL: storyURL });
		Linking.canOpenURL(storyURL).then(supported => {
		if (!supported) {
			console.log('Can\'t handle url: ' + storyURL);
		} else {
			return Linking.openURL(storyURL);
		}
		}).catch(err => console.error('An error with opening NewsDetail occurred', err));
	}

	getStoryDescription(description, title){
		var storyDescriptionStr = description.replace(/^ /g, '');

		storyDescriptionStr = storyDescriptionStr.substring(0,150).replace(/ $/,'') + '...';

		return storyDescriptionStr;
	}

	render() {
		var data = this.props.data;

		var storyDate = data['date'];
		var storyDateMonth = storyDate.substring(5,7);
		var storyDateDay = storyDate.substring(8,10);

		if (storyDateMonth.substring(0,1) == '0') {
			storyDateMonth = storyDateMonth.substring(1,2);
		}
		if (storyDateDay.substring(0,1) == '0') {
			storyDateDay = storyDateDay.substring(1,2);
		}

		var storyDateMonthStr = monthNames[storyDateMonth-1];

		var storyTitle = data.title;

		var storyDescriptionStr = this.getStoryDescription(data.description, data.title);

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoNewsDetail(this.props.data)}>
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
							<Image style={css.events_card_image} source={{ uri: data.image }} />
						) : (
							<Image style={css.events_card_image} source={ require('../../assets/img/MobileEvents_blank.jpg')} />
						)}
					</View>
				</View>
			</TouchableHighlight>
		)
	}
}
