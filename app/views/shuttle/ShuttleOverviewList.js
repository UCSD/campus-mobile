import React from 'react'
import { FlatList, View } from 'react-native'
import { withNavigation } from 'react-navigation'

import ShuttleOverview from './ShuttleOverview'
import css from '../../styles/css'
import { LAYOUT } from '../../styles/LayoutConstants'

const ShuttleOverviewList = ({ navigation, savedStops, stopsData, gotoRoutesList }) => {
	let list
	if (Array.isArray(savedStops) && savedStops.length > 1) {
		list = (
			<FlatList
				style={css.flexrow}
				scrollEnabled={false}
				showsVerticalScrollIndicator={false}
				showsHorizontalScrollIndicator={false}
				horizontal={true}
				snapToInterval={LAYOUT.MAX_CARD_WIDTH - 50 - 12}
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
		)
	}

	return (
		<View style={css.flexrow}>
			{list}
		</View>
	)
}

export default withNavigation(ShuttleOverviewList)
