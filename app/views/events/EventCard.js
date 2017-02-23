import React from 'react';
import {
	View,
	Text,
	TouchableHighlight
} from 'react-native';

import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import EventList from './EventList';
import css from '../../styles/css';
import { doPRM } from '../../util/general';

const defaultRows = 3;

const EventCard = ({ data }) => (
	<Card id="events" title="Events">
		<View style={css.events_list}>
			{data ? (
				<View>
					<EventList
						data={data}
						rows={defaultRows}
						scrollEnabled={false}
					/>
					<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.EventListView({ data })}>
						<View style={css.events_more}>
							<Text style={css.events_more_label}>View All Events</Text>
						</View>
					</TouchableHighlight>
				</View>
			) : (
				<Text style={css.content_load_err}>There was a problem loading events.</Text>
			)}
		</View>
	</Card>
);

export default EventCard;
