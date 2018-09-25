import React, { Component } from 'react'
import { View, Text } from 'react-native'
import css from '../../styles/css'
import ParkingDetail from './ParkingDetail'
import LAYOUT from '../../styles/LayoutConstants'

class ParkingOverview extends Component {
	getTotalSpots() {
		const { structureData, spotsSelected } = this.props
		let totalAvailableSpots = 0
		for (let i = 0; i < spotsSelected.length; i++) {
			const parkingSpotsPerType = structureData.Availability[spotsSelected[i]]
			if (parkingSpotsPerType) {
				for (let j = 0; j < parkingSpotsPerType.length; j++) {
					totalAvailableSpots += Number(parkingSpotsPerType[j].Open)
				}
			}
		}
		return totalAvailableSpots
	}

	getOpenPerType(currentType) {
		const { structureData } = this.props
		const tempType = structureData.Availability[currentType]
		let openPerType = 0
		if (tempType) {
			for (let i = 0; i < tempType.length; i++) {
				openPerType += Number(tempType[i].Open)
			}
		}
		return openPerType
	}

	getTotalPerType(currentType) {
		const { structureData } = this.props

		const tempType = structureData.Availability[currentType]
		let totalPerType = 0
		if (tempType) {
			for (let i = 0; i < tempType.length; i++) {
				totalPerType += Number(tempType[i].Total)
			}
		}
		return totalPerType
	}

	displaySpots() {
		const message = 'Please select parking type'
		if (this.getTotalSpots() === 0) {
			return message
		} else {
			return this.getTotalSpots()
		}
	}

	renderDetails() {
		const { spotsSelected } = this.props
		if (spotsSelected.length === 0) {
			return null
		} else if (spotsSelected.length === 1) {
			return (
				<View style={css.po_one_spot_selected}>
					<ParkingDetail
						spotType={spotsSelected[0]}
						spotsAvailable={this.getOpenPerType(spotsSelected[0])}
						totalSpots={this.getTotalPerType(spotsSelected[0])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.38}
						widthMultiplier={15}
						circleRadius={32}
						letterSize={35}
						progressNumber={48}
						progressPercent={20}
					/>
				</View>
			)
		} else if (spotsSelected.length === 2) {
			return (
				<View style={css.po_two_spots_selected}>
					<ParkingDetail
						spotType={spotsSelected[0]}
						spotsAvailable={this.getOpenPerType(spotsSelected[0])}
						totalSpots={this.getTotalPerType(spotsSelected[0])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.32}
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.035}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.137) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.075}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.1}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.05}
					/>
					<View style={{ paddingHorizontal: 20 }} />
					<ParkingDetail
						spotType={spotsSelected[1]}
						spotsAvailable={this.getOpenPerType(spotsSelected[1])}
						totalSpots={this.getTotalPerType(spotsSelected[1])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.32}
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.035}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.137) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.075}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.1}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.05}
					/>
				</View>
			)
		} else {
			return (
				<View style={css.po_three_spots_selected}>
					<ParkingDetail
						spotType={spotsSelected[0]}
						spotsAvailable={this.getOpenPerType(spotsSelected[0])}
						totalSpots={this.getTotalPerType(spotsSelected[0])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.25}
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.028}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.128) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.068}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.08}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.045}
					/>
					<View style={{ paddingHorizontal: 10 }} />
					<ParkingDetail
						spotType={spotsSelected[1]}
						spotsAvailable={this.getOpenPerType(spotsSelected[1])}
						totalSpots={this.getTotalPerType(spotsSelected[1])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.25}
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.028}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.128) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.068}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.08}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.045}
					/>
					<View style={{ paddingHorizontal: 10 }} />
					<ParkingDetail
						spotType={spotsSelected[2]}
						spotsAvailable={this.getOpenPerType(spotsSelected[2])}
						totalSpots={this.getTotalPerType(spotsSelected[2])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.25}
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.028}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.128) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.068}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.08}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.045}
					/>
				</View>
			)
		}
	}

	render() {
		const { structureData, spotsSelected } = this.props
		const message = 'Please select a parking type'
		const lotName = structureData.LocationName.replace('Parking ','') + ' Availability'

		return (
			<View style={{ flex: 1, width: LAYOUT.MAX_CARD_WIDTH }}>
				<Text style={css.po_structure_name}>{lotName}</Text>
				<Text style={css.po_structure_spots_available}>
					{spotsSelected.length === 0 ? message : '~ ' + this.getTotalSpots() + ' Spots'}
				</Text>
				{this.renderDetails()}
			</View>
		)
	}
}

export default ParkingOverview
