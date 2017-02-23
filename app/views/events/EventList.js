import React from 'react';
import {
	View,
	ListView,
} from 'react-native';

import EventItem from './EventItem';
import { doPRM } from '../../util/general';

const eventDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const EventList = ({ data, rows, scrollEnabled }) => (
	<ListView
		scrollEnabled={scrollEnabled}
		dataSource={eventDataSource.cloneWithRows(data.slice(0,rows))}
		renderRow={(row) => (
			<EventItem data={row} />
		)}
	/>
);

export default EventList;