import React from 'react'
import { connect } from 'react-redux'
import SurfButton from './SurfButton'
import WeatherCard from './WeatherCard'

export const WeatherCardContainer = ({ weatherData }) => (
	<WeatherCard
		weatherData={weatherData}
		actionButton={<SurfButton />}
	/>
)

const mapStateToProps = state => ({	weatherData: state.weather.data })
const ActualWeatherCard = connect(mapStateToProps)(WeatherCardContainer)
export default ActualWeatherCard
