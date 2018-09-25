import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withNavigation } from 'react-navigation'
import ParkingCard from './ParkingCard'

export class ParkingCardContainer extends Component {
	gotoParkingSpotType = (navigation) => {
		navigation.navigate('ParkingSpotType')
	}

	render() {
		const { navigation, parkingData, count, selectedSpots } = this.props
		return (
			<ParkingCard
				savedStructures={parkingData}
				gotoParkingSpotType={() => this.gotoParkingSpotType(navigation)}
				mySpots={selectedSpots}
				lotCount={count}
			/>
		)
	}
}

const mapStateToProps = state => (
	{
		parkingData: state.parking.parkingData,
		isChecked: state.parking.isChecked,
		count: state.parking.count,
		selectedSpots: state.parking.selectedSpots
	}
)


const ActualParkingCard = connect(mapStateToProps)(withNavigation(ParkingCardContainer))
export default ActualParkingCard
