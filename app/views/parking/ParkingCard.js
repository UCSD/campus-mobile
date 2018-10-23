import React from 'react'
import { View, Text } from 'react-native'
import { withNavigation } from 'react-navigation'
import ScrollCard from '../common/ScrollCard'
import Card from '../common/Card'
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
			name: 'Edit Spot Type',
			action: gotoParkingSpotType
		},
		{
			name: 'Manage Parking Lots',
			action: gotoManageParkingLots
		}
	]

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
			/>
		)
	} else {
		return (
			<Card
				id="parking"
				title="Parking"
				extraActions={extraActions}
			>
				<View style={css.po_container}>
					<Text style={css.po_structure_spots_available}>Please select a parking lot</Text>
				</View>
			</Card>
		)
	}
}

export default withNavigation(ParkingCard)
