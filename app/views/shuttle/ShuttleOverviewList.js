import React from 'react';
import {
	ListView,
	View,
	TouchableOpacity,
	Text
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import ShuttleOverview from './ShuttleOverview';
import { getMaxCardWidth } from '../../util/general';

const stopsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ShuttleOverviewList = ({ savedStops, stopsData, gotoRoutesList }) => {
	let list;
	if (savedStops !== {}) {
		list = (
			<ListView
				style={{ flexDirection: 'row' }}
				scrollEnabled={true}
				showsVerticalScrollIndicator={false}
				horizontal={true}
				snapToInterval={getMaxCardWidth() 12}
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
		<View>
			{list}
			<TouchableOpacity
				onPress={() => gotoRoutesList()}
			>
				<Text>
					Add Stop
				</Text>
			</TouchableOpacity>
		</View>
	);
};

export default ShuttleOverviewList;
