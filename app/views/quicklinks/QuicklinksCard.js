import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import { Actions } from 'react-native-router-flux';
import Card from '../card/Card';
import QuicklinksList from './QuicklinksList';

import general from '../../util/general';

const css = require('../../styles/css');

const defaultRows = 4;

const QuicklinksCard = ({ data }) => (
	<Card title="Links" id="quicklinks">
		{data ? (
			<View style={css.quicklinks_card}>
				<View style={css.quicklinks_locations}>
					<QuicklinksList
						data={data.slice().sort(general.dynamicSort('card-order')).slice(0,defaultRows)} // Try to get rid of this sort eventually?
						listType={'card'}
						scrollEnabled={false}
					/>
				</View>
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.QuicklinksListView({ data })}>
					<View style={css.card_more}>
						<Text style={css.card_more_label}>View All Links</Text>
					</View>
				</TouchableHighlight>
			</View>
		) : null }
	</Card>
);

export default QuicklinksCard;
