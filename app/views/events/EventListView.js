import React from 'react';
import {
	View,
	ListView,
} from 'react-native';

import EventItemCard from './EventItemCard';

const css = require('../../styles/css');
const logger = require('../../util/logger');

const eventDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const EventListView = ({ data }) => {
	logger.ga('View Loaded: Event List View');

	return (
		<View style={css.main_container}>
			<ListView
				style={css.welcome_listview}
				dataSource={eventDataSource.cloneWithRows(data)}
				renderRow={(row) => (
					<EventItemCard data={row} />
				)}
			/>
		</View>
	);
};

export default EventListView;
