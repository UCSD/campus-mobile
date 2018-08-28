import React from 'react'
import { View, Text } from 'react-native'
import { connect } from 'react-redux'
import logger from '../../util/logger'

/**
 * Container component for [ParkingCard]{@link ParkingCard}
**/
export const ParkingCardContainer = ({ parkingData }) => {
	logger.ga('Card Mounted: Parking')
	return (
		<View>
			<Text>Parking Card Hello!</Text>
		</View>
	)
}

const mapStateToProps = state => ({ parkingData: state.weather.data })
const ActualParkingCard = connect(mapStateToProps)(ParkingCardContainer)
export default ActualParkingCard
