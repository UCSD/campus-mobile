import React, { Component } from 'react'
import { View, Text } from 'react-native'
import css from '../../styles/css'
import ParkingDetail from './ParkingDetail'

class ParkingOverview extends Component {
	getTotalSpots() {
		const { structureData, selectedSpots } = this.props

		let totalAvailableSpots = 0
		for (let i = 0; i < selectedSpots.length; i++) {
			const parkingSpotsPerType = structureData[0].Availability[selectedSpots[i]]
			// have this just incase the parking lot does not contain a certain type of parking
			// if we dont have this then app crashes
			if (parkingSpotsPerType) {
				for (let j = 0; j < parkingSpotsPerType.length; j++) {
					totalAvailableSpots += Number(parkingSpotsPerType[j].Open)
				}
			}
		}
		return totalAvailableSpots
	}

	renderDetails() {
		const { structureData, selectedSpots } = this.props
		if (selectedSpots.length === 0) {
			return null
		}
		else if (selectedSpots.length === 1) {
			return (
				<View>
					<ParkingDetail spotType={selectedSpots[0]} spotsAvailable={structureData[0].Availability[selectedSpots[0]][0].Open} totalSpots={structureData[0].Availability[selectedSpots[0]][0].Total} />
				</View>
			)
		}
		else if (selectedSpots.length === 2) {
			return (
				<View>
					<ParkingDetail spotType={selectedSpots[0]} />
					<ParkingDetail spotType={selectedSpots[1]} />
				</View>
			)
		}
		else {
			return (
				<View>
					<ParkingDetail spotType={selectedSpots[0]} />
					<ParkingDetail spotType={selectedSpots[1]}  />
					<ParkingDetail spotType={selectedSpots[2]}  />
				</View>
			)
		}
	}

	render() {
		const { structureData } = this.props
		return (
			<View>
				<Text style={css.po_structure_name}>
					{structureData.LocationName}
				</Text>
				<Text style={css.po_structure_spots_available}>
					~ {this.getTotalSpots()} Spots
				</Text>
				{this.renderDetails()}
			</View>
		)
	}
}

export default ParkingOverview
