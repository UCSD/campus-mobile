import React from 'react'
import {
	View,
	Text,
	Image,
} from 'react-native'

import css from '../../styles/css'
import AppSettings from '../../AppSettings'

/**
 * Presentational Component for WeatherDay
 * @param  {Object} data Weather data
 * @param {String} data.dayofweek 3-letter representation for day of the week
 * @param {String} data.icon Part of icon filename
 * @param {Number} data.tempMax Max temperature for day
 * @param {Number} data.tempMin Min temperature for day
 * @return {JSX} Presentational Component for WeatherCard
 *
 * @todo Provide icon default using non-image urls?
 */
const WeatherDay = ({ data }) => (
	<View style={css.wd_dayContainer}>
		<Text style={css.wd_dayText}>
			{data.dayofweek}
		</Text>
		<Image
			style={css.wd_icon}
			source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + data.icon + '.png' }}
		/>
		<Text style={css.wd_maxText}>
			{data.tempMax}&deg;
		</Text>
		<Text style={css.wd_minText}>
			{data.tempMin}&deg;
		</Text>
	</View>
)

export default WeatherDay
