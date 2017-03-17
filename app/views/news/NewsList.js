import React from 'react';
import {
	View,
	ListView,
} from 'react-native';

import NewsItem from './NewsItem';

const newsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const NewsList = ({ data, rows, scrollEnabled }) => (
	<ListView
		scrollEnabled={scrollEnabled}
		dataSource={newsDataSource.cloneWithRows(data.slice(0,rows))}
		renderRow={(row) => (
			<NewsItem data={row} />
		)}
	/>
);

export default NewsList;
