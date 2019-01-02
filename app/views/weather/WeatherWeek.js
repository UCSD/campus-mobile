import React from 'react'
import PropTypes from 'prop-types'
import { View } from 'react-native'

import WeatherDay from './WeatherDay'
import css from '../../styles/css'

/**
 * Presentational Component for WeatherWeek row
 * @param {Object[]} weatherData Weather data for next 5 days
 * @param {String} weatherData[].dayofweek 3-letter representation for day of the week
 * @param {String} weatherData[].icon Part of icon filename
 * @param {Number} weatherData[].tempMax Max temperature for day
 * @param {Number} weatherData[].tempMin Min temperature for day
 * @return {JSX} Presentational Component for WeatherCard
 */
const WeatherWeek = ({ weatherData }) => (
	<View style={css.ww_weekContainer}>
		{weatherData.data.map((val,index) =>
			<WeatherDay key={index} data={val} />
		)}
	</View>
)

WeatherWeek.propTypes = {
	weatherData: PropTypes.object,
}

export default WeatherWeek
