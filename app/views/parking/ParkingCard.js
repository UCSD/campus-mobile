import React from 'react'
import { View, Text } from 'react-native'
import { withNavigation } from 'react-navigation'
import ScrollCard from '../common/ScrollCard'
import Card from '../common/Card'
import Touchable from '../common/Touchable'
import ParkingOverview from './ParkingOverview'
import css from '../../styles/css'

const ParkingCard = ({
	savedStructures,
	navigation,
	gotoParkingSpotType,
	gotoManageParkingLots,
	selectedSpots,
	selectedLots
}) => {
	const extraActions = [
		{
			name: 'Spot Types',
			action: gotoParkingSpotType
		},
		{
			name: 'Manage Lots',
			action: gotoManageParkingLots
		}
	]

	const ManageLotsButton = (
		<Touchable
			style={css.card_button_container}
			onPress={() => { navigation.navigate('ManageParkingLots') }}
		>
			<Text style={css.card_button_text}>Manage Lots</Text>
		</Touchable>
	)

	// only display the selcted parking lots
	const data = []
	savedStructures.forEach((obj) => {
		if (selectedLots.includes(obj.LocationName)) {
			data.push(obj)
		}
	})
	const lotCount = data.length
	if (lotCount > 0) {
		return (
			<ScrollCard
				id="parking"
				title="Parking"
				renderItem={({ item }) => (
					<ParkingOverview
						structureData={item}
						selectedSpots={selectedSpots}
						totalLotCount={savedStructures.length}
					/>
				)}
				extraData={selectedSpots}
				scrollData={data}
				extraActions={extraActions}
				actionButton={ManageLotsButton}
			/>
		)
	} else {
		return (
			<Card
				id="parking"
				title="Parking"
				extraActions={extraActions}
			>
				<View style={css.pc_nolots_container}>
					<Text style={css.pc_nolots_text}>Add a parking lot to begin.</Text>
				</View>
				{ManageLotsButton}
			</Card>
		)
	}
}

export default withNavigation(ParkingCard)
