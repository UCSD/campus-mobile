import React, { Component } from 'react'
import { connect } from 'react-redux'
import ParkingCard from './ParkingCard'

export const ParkingCardContainer = ({ weatherData }) => {
	return (
		<ParkingCard />
	)
}

const mapStateToProps = state => ({ parkingData: state.weather.data })
const ActualParkingCard = connect(mapStateToProps)(ParkingCardContainer)
export default ActualParkingCard
