import React from 'react'
import { withNavigation } from 'react-navigation'
import ScrollCard from '../common/ScrollCard'
import ParkingOverview from './ParkingOverview'

const ParkingCard = ({ savedStructures, navigation, gotoParkingSpotType, selectedSpots }) => {
	const extraActions = [
		{
			name: 'Edit Spot Type',
			action: gotoParkingSpotType
		}
	]
	return (
		<ScrollCard
			id="parking"
			title="Parking Availability"
			scrollData={savedStructures}
			renderItem={() => (
				<ParkingOverview
					selectedSpots={selectedSpots}
					structureData={savedStructures}
				/>
			)}
			extraActions={extraActions}
		/>
	)
}

export default withNavigation(ParkingCard)
