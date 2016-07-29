'use strict'

import React from 'react'
import {
	StyleSheet,
	View,
	Text,
	Navigator,
	TouchableHighlight,
	Image,
} from 'react-native';

import TopStoriesDetail from './TopStoriesDetail';

var css = require('../../styles/css');

const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export default class TopStoresItem extends React.Component {

  gotoTopStoriesDetail(topStoriesData) {
  		this.props.navigator.push({ id: 'TopStoriesDetail', component: TopStoriesDetail, title: 'News', topStoriesData: topStoriesData });
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

		var storyDescriptionStr = data.description;
		storyDescriptionStr = storyDescriptionStr.replace(/^ /g, '');

		if (storyDescriptionStr.length > 0) {
			if (storyTitle.length < 25) {
				storyDescriptionStr = storyDescriptionStr.substring(0,56).replace(/ $/,'') + '...';
			} else if (storyTitle.length < 50) {
				storyDescriptionStr = storyDescriptionStr.substring(0,28).replace(/ $/,'') + '...';
			} else {
				storyDescriptionStr = '';
			}
		}

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoTopStoriesDetail(data) }>
				<View style={css.events_list_row}>
					<View style={css.events_list_left_container}>
						<Text style={css.events_list_title}>{storyTitle}</Text>
						{storyDescriptionStr ? (
							<Text style={css.events_list_desc}>{storyDescriptionStr}</Text>
						) : null }
						<Text style={css.events_list_postdate}>{storyDateMonthStr} {storyDateDay}</Text>
					</View>

					{data.image ? (
						<Image style={css.events_list_image} source={{ uri: data.image }} />
					) : (
						<Image style={css.events_list_image} source={ require('../../assets/img/MobileEvents_blank.jpg')} />
					)}

				</View>
			</TouchableHighlight>
		);
	}
}
