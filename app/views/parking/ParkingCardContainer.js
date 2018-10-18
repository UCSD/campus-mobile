import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withNavigation } from 'react-navigation'
import ParkingCard from './ParkingCard'

export class ParkingCardContainer extends Component {
	gotoParkingSpotType = (navigation) => {
		navigation.navigate('ParkingSpotType')
	}
	gotoManageParkingLots = (navigation) => {
		navigation.navigate('ManageParkingLots')
	}

	render() {
		const {
			navigation,
			parkingData,
			count,
			selectedSpots,
			selectedLots
		} = this.props
		return (
			<ParkingCard
				savedStructures={parkingData}
				gotoParkingSpotType={() => this.gotoParkingSpotType(navigation)}
				gotoManageParkingLots={() => this.gotoManageParkingLots(navigation)}
				mySpots={selectedSpots}
				lotCount={count}
				selectedLots={selectedLots}
			/>
		)
	}
}

const mapStateToProps = state => (
	{
		parkingData: state.parking.parkingData,
		isChecked: state.parking.isChecked,
		count: state.parking.count,
		selectedSpots: state.parking.selectedSpots,
		selectedLots: state.parking.selectedLots
	}
)


const ActualParkingCard = connect(mapStateToProps)(withNavigation(ParkingCardContainer))
export default ActualParkingCard
