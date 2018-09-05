import React from 'react'
import { withNavigation } from 'react-navigation'
import ScrollCard from '../common/ScrollCard'

export const ParkingCard = ({ navigation, gotoParkingSpotType }) => {
	const extraActions = [
		{
			name: 'Edit parking spot type',
			action: gotoParkingSpotType
		}
	]
	return (
		<ScrollCard
			id="parking"
			title="Parking Availability"
			extraActions={extraActions}
		/>
	)
}

export default withNavigation(ParkingCard)
