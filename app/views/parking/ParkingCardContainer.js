import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withNavigation } from 'react-navigation'
import ParkingCard from './ParkingCard'

export class ParkingCardContainer extends React.Component {
	gotoParkingSpotType = (navigation) => {
		navigation.navigate('ParkingSpotType')
	}

	render() {
		const { navigation } = this.props
		return (
			<ParkingCard
				gotoParkingSpotType={() => this.gotoParkingSpotType(navigation)}
			/>
		)
	}
}

const mapStateToProps = state => ({ parkingData: state.parking.data })
const ActualParkingCard = connect(mapStateToProps)(withNavigation(ParkingCardContainer))
export default ActualParkingCard
