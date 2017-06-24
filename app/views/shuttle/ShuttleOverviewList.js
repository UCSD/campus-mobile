import React from 'react';
import {
	ListView,
	View,
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import ShuttleOverview from './ShuttleOverview';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';

const stopsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ShuttleOverviewList = ({ savedStops, stopsData, gotoRoutesList }) => {
	let list;
	if (Array.isArray(savedStops) && savedStops.length > 1) {
		list = (
			<ListView
				style={{ flexDirection: 'row' }}
				scrollEnabled={false}
				showsVerticalScrollIndicator={false}
				showsHorizontalScrollIndicator={false}
				horizontal={true}
				snapToInterval={MAX_CARD_WIDTH - 50 - 12}
				dataSource={stopsDataSource.cloneWithRows(savedStops)}
				renderRow={
					(row, sectionID, rowID) =>
						<ShuttleOverview
							onPress={() => Actions.ShuttleStop({ stopID: row.id })}
							stopData={stopsData[row.id]}
						/>
				}
			/>
		);
	}

	return (
		<View style={{ flexDirection: 'row' }}>
			{list}
		</View>
	);
};

export default ShuttleOverviewList;
