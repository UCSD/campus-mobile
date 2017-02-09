import React from 'react';
import {
	ListView,
} from 'react-native';

import QuicklinksItem from './QuicklinksItem';

const linksDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const QuicklinksList = ({ data, scrollEnabled }) => (
	<ListView
		dataSource={linksDataSource.cloneWithRows(data)}
		renderRow={
			(row) => <QuicklinksItem data={row} />
		}
		scrollEnabled={scrollEnabled}
	/>
);

export default QuicklinksList;
