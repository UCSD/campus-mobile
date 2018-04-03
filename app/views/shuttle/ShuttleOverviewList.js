import React from 'react';
import {
	FlatList,
	View,
} from 'react-native';
import { withNavigation } from 'react-navigation';

import ShuttleOverview from './ShuttleOverview';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';

const ShuttleOverviewList = ({ navigation, savedStops, stopsData, gotoRoutesList }) => {
	let list;
	if (Array.isArray(savedStops) && savedStops.length > 1) {
		list = (
			<FlatList
				style={{ flexDirection: 'row' }}
				scrollEnabled={false}
				showsVerticalScrollIndicator={false}
				showsHorizontalScrollIndicator={false}
				horizontal={true}
				snapToInterval={MAX_CARD_WIDTH - 50 - 12}
				dataSource={savedStops}
				renderItem={
					({ item: rowData }) => (
						<ShuttleOverview
							onPress={() => navigation.navigate('ShuttleStop', { stopID: rowData.id })}
							stopData={stopsData[rowData.id]}
						/>
					)
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

export default withNavigation(ShuttleOverviewList);
