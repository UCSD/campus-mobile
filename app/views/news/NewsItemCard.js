import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import { Actions } from 'react-native-router-flux';

const css = require('../../styles/css');
const moment = require('moment');

const NewsItem = ({ data }) => (
	<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.NewsDetail({ data })}>
		<View style={css.card_main}>
			<View style={css.events_card_title_container}>
				<Text style={css.events_card_title}>{data.title}</Text>
			</View>
			<View style={css.events_card_container}>
				<View style={css.events_card_left_container}>
					{data.description ? (
						<Text
							style={css.events_card_desc}
							numberOfLines={3}
						>
							{data.description}
						</Text>
					) : null }
					<Text style={css.events_card_postdate}>
						{moment(data.date).format('MMM Do, YYYY')}
					</Text>
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

export default NewsItem;
