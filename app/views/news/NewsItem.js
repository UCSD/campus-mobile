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
		<View style={css.events_list_row}>
			<Text
				style={css.events_list_title}
				numberOfLines={1}
			>
				{data.title}
			</Text>

			<View style={css.events_list_info}>
				<View style={css.events_list_info_left}>
				
					{data.description ? (
						<Text
							style={css.events_list_desc}
							numberOfLines={3}
						>
							{/* TODO: Remove trim once feed is fixed */}
							{data.description.trim()}
							}
						</Text>
					) : null }
					<Text style={css.events_list_postdate}>{moment(data.date).format('MMM Do, YYYY')}</Text>
				</View>

				{data.image ? (
					<Image style={css.events_list_image} source={{ uri: data.image }} />
				) : (
					<Image style={css.events_list_image} source={require('../../assets/img/MobileEvents_blank.jpg')} />
				)}
			</View>
		</View>
	</TouchableHighlight>
);

export default NewsItem;
