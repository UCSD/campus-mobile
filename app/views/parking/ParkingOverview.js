import React, { Component } from 'react'
import { View, Text } from 'react-native'
import css from '../../styles/css'
import ParkingDetail from './ParkingDetail'
import LAYOUT from '../../styles/LayoutConstants'
import logger from '../../util/logger'

class ParkingOverview extends Component {
	getTotalSpots() {
		try {
			const { structureData, spotsSelected } = this.props
			let totalAvailableSpots = 0
			if (Array.isArray(spotsSelected)) {
				for (let i = 0; i < spotsSelected.length; i++) {
					if (structureData.Availability && spotsSelected[i]) {
						const parkingSpotsPerType = structureData.Availability[spotsSelected[i]]
						if (Array.isArray(parkingSpotsPerType)) {
							for (let j = 0; j < parkingSpotsPerType.length; j++) {
								totalAvailableSpots += Number(parkingSpotsPerType[j].Open)
							}
						}
					}
				}
			}
			return totalAvailableSpots
		} catch (error) {
			logger.trackException(error, false)
			return 0
		}
	}

	// this function returns the number of parking spots open of a given type
	// returns -1 if the structure does not have the specific type
	getOpenPerType(currentType) {
		const { structureData } = this.props

		const tempType = structureData.Availability[currentType]
		let openPerType = 0
		if (tempType) {
			for (let i = 0; i < tempType.length; i++) {
				openPerType += Number(tempType[i].Open)
			}
			return openPerType
		} else {
			return -1
		}
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
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.037}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.14) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.08}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.14}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.06}
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
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.032}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.137) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.075}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.12}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.05}
					/>
					<View style={css.po_acp_gap_1} />
					<ParkingDetail
						spotType={spotsSelected[1]}
						spotsAvailable={this.getOpenPerType(spotsSelected[1])}
						totalSpots={this.getTotalPerType(spotsSelected[1])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.32}
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.032}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.137) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.075}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.12}
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
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.025}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.124) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.062}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.08}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.035}
					/>
					<View style={css.po_acp_gap_2} />
					<ParkingDetail
						spotType={spotsSelected[1]}
						spotsAvailable={this.getOpenPerType(spotsSelected[1])}
						totalSpots={this.getTotalPerType(spotsSelected[1])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.25}
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.025}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.124) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.062}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.08}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.035}
					/>
					<View style={css.po_acp_gap_2} />
					<ParkingDetail
						spotType={spotsSelected[2]}
						spotsAvailable={this.getOpenPerType(spotsSelected[2])}
						totalSpots={this.getTotalPerType(spotsSelected[2])}
						size={LAYOUT.MAX_CARD_WIDTH * 0.25}
						widthMultiplier={LAYOUT.MAX_CARD_WIDTH * 0.025}
						circleRadius={(LAYOUT.MAX_CARD_WIDTH * 0.124) / 2}
						letterSize={LAYOUT.MAX_CARD_WIDTH * 0.062}
						progressNumber={LAYOUT.MAX_CARD_WIDTH * 0.08}
						progressPercent={LAYOUT.MAX_CARD_WIDTH * 0.035}
					/>
				</View>
			)
		}
	}

	render() {
		const { structureData, spotsSelected } = this.props
		let message
		if (Array.isArray(spotsSelected) && spotsSelected.length > 0) {
			const totalSpots = this.getTotalSpots()
			if (totalSpots === 1) {
				message = '~' + totalSpots + ' Spot Available'
			} else {
				message = '~' + totalSpots + ' Spots Available'
			}
		} else {
			message = 'Please select a parking type'
		}

		return (
			<View style={css.po_container}>
				<Text style={css.po_structure_name}>{structureData.LocationName}</Text>
				<Text style={css.po_structure_context}>{structureData.LocationContext}</Text>
				<Text style={css.po_structure_spots_available}>{message}</Text>
				{this.renderDetails()}
				<Text style={css.po_structure_comingsoon}>More Lots Coming Soon!</Text>
			</View>
		)
	}
}

export default ParkingOverview
