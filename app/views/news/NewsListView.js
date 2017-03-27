import React from 'react';
import {
	View,
	ListView,
} from 'react-native';

import NewsItemCard from './NewsItemCard';

const css = require('../../styles/css');
const logger = require('../../util/logger');

const eventDatasource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const NewsListView = ({ data }) => {
	logger.ga('View Loaded: News List View');

	return (
		<View style={css.main_container}>
			<ListView
				style={css.welcome_listview}
				dataSource={eventDatasource.cloneWithRows(data)}
				renderRow={(row) => <NewsItemCard data={row} />}
			/>
		</View>
	);
};

export default NewsListView;
