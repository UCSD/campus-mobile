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

const EventCard = ({ data }) => (
	<Card id="events" title="Events">
		<View style={css.events_list}>
			{data ? (
				<View>
					<EventList
						data={data}
						rows={3}
						scrollEnabled={false}
					/>
					<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.EventListView({ data })}>
						<View style={css.events_more}>
							<Text style={css.events_more_label}>View All Events</Text>
						</View>
					</TouchableHighlight>
				</View>
			) : (
				<View style={[css.flexcenter, css.pad40]}>
					<Text>There was a problem loading events, try back soon.</Text>
				</View>
			)}
		</View>
	</Card>
);

export default EventCard;
