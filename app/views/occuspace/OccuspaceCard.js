import React from 'react'
import { View, Text } from 'react-native'
import { withNavigation } from 'react-navigation'
import ScrollCard from '../common/ScrollCard'
import Card from '../common/Card'
import Touchable from '../common/Touchable'
import css from '../../styles/css'
import OccuspaceView from './OccuspaceView'
import { getSelectedOccusapceLocations } from '../../util/occuspace'

const OccupsaceCard = ({
	occuspaceData,
	goToManageLocations,
	selectedLocations
}) => {
	const extraActions = [
		{
			name: 'Manage Locations',
			action: goToManageLocations
		},
	]

	const ManageLocationButton = (
		<Touchable
			style={css.card_button_container}
			onPress={() => goToManageLocations()}
		>
			<Text style={css.card_button_text}>Manage Locations</Text>
		</Touchable>
	)
	const data = getSelectedOccusapceLocations(occuspaceData, selectedLocations)
	const locationCount = data.length
	if (locationCount > 0) {
		return (
			<ScrollCard
				id="occuspace"
				title="Busyness"
				renderItem={({ item }) => (
					<OccuspaceView
						data={item}
					/>
				)}
				extraData={selectedLocations}
				scrollData={data}
				extraActions={extraActions}
				actionButton={ManageLocationButton}
			/>
		)
	} else {
		return (
			<Card
				id="occuspace"
				title="Busyness"
				extraActions={extraActions}
			>
				<View style={css.pc_nolots_container}>
					<Text style={css.pc_nolots_text}>Add a location to begin.</Text>
				</View>
				{ManageLocationButton}
			</Card>
		)
	}
}

export default withNavigation(OccupsaceCard)
