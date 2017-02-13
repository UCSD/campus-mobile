import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import NewsList from './NewsList';
import css from '../../styles/css';
import { doPRM } from '../../util/general';

const defaultRows = 3;

const NewsCard = ({ data }) => (
	<Card id="news" title="News">
		<View style={[css.events_list, { height: getRowHeight(defaultRows) }]}>
			{data ? (
				<View>
					<NewsList
						data={data}
						rows={defaultRows}
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

function getRowHeight(rows) {
	// titleFont + 3*(descFont + descPad) + dateFont + datePad
	const rowHeight =  doPRM(17) + (3 * (doPRM(14) + doPRM(8))) + doPRM(11) + doPRM(8);
	const padding = 28; // rowPad

	return rows * (rowHeight + padding);
}

export default NewsCard;
