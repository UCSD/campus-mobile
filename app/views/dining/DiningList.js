import React from 'react';
import {
	ListView,
} from 'react-native';

import DiningItem from './DiningItem';

const diningDatasource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const DiningList = ({ data, rows }) => (
	<ListView
		dataSource={diningDatasource.cloneWithRows(data.slice(0, rows))}
		renderRow={
			(row) => <DiningItem data={row} />
		}
	/>
);

export default DiningList;
