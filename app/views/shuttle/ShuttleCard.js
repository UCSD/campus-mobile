import React from 'react'
import { Text } from 'react-native'
import { withNavigation } from 'react-navigation'

import ShuttleOverview from './ShuttleOverview'
import ScrollCard from '../common/ScrollCard'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

export const ShuttleCard = ({
	navigation,
	stopsData,
	savedStops,
	gotoRoutesList,
	gotoSavedList,
	updateScroll,
	lastScroll,
}) => {
	const extraActions = [
		{
			name: 'Manage Stops',
			action: gotoSavedList
		}
	]
	console.log(savedStops)
	return (
		<ScrollCard
			id="shuttle"
			title="Shuttle"
			scrollData={savedStops}
			renderItem={
				({ item: rowData }) => (
					<ShuttleOverview
						onPress={() => navigation.navigate('ShuttleStop', { stopID: rowData.id })}
						stopData={stopsData[rowData.id]}
						closest={Object.prototype.hasOwnProperty.call(rowData, 'savedIndex')}
					/>
				)
			}
			actionButton={
				<Touchable
					style={css.shuttlecard_addButton}
					onPress={() => gotoRoutesList()}
				>
					<Text style={css.shuttlecard_addText}>Add a Stop</Text>
				</Touchable>
			}
			extraActions={extraActions}
			updateScroll={updateScroll}
			lastScroll={lastScroll}
		/>
	)
}

export default withNavigation(ShuttleCard)
