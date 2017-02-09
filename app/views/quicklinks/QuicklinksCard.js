import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import { Actions } from 'react-native-router-flux';
import Card from '../card/Card';
import QuicklinksList from './QuicklinksList';

const css = require('../../styles/css');

const QuicklinksCard = ({ data }) => (
	<Card title="Links">
		{data ? (
			<View style={css.quicklinks_card}>
				<View style={css.quicklinks_locations}>
					<QuicklinksList
						data={data}
						scrollEnabled={false}
					/>
				</View>
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.QuicklinksListView({ data })}>
					<View style={css.card_more}>
						<Text style={css.card_more_label}>View All</Text>
					</View>
				</TouchableHighlight>
			</View>
		) : null }
	</Card>
);

export default QuicklinksCard;
