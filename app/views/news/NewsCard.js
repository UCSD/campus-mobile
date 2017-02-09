import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import NewsList from './NewsList';

const css = require('../../styles/css');

const NewsCard = ({ data }) => (
	<Card id="news" title="News">
		<View style={css.events_list}>
			{data ? (
				<View>
					<NewsList
						data={data}
						rows={3}
						scrollEnabled={false}
					/>
					<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.NewsListView({ data })}>
						<View style={css.events_more}>
							<Text style={css.events_more_label}>View All News</Text>
						</View>
					</TouchableHighlight>
				</View>
			) :
			(
				<View style={[css.flexcenter, css.pad40]}>
					<Text>There was a problem loading the news</Text>
				</View>
			)}
		</View>
	</Card>
);

export default NewsCard;
