import React from 'react'
import PropTypes from 'prop-types'
import {
	View,
	Text,
	Image,
	ActivityIndicator,
} from 'react-native'

import Card from '../common/Card'
import WeatherWeek from './WeatherWeek'
import css from '../../styles/css'
import AppSettings from '../../AppSettings'

/**
 * Presentational Component for WeatherCard
 * @param  {Object} weatherData Weather data
 * @param {Object} weatherData.currently Weather data for today
 * @param {Number} weatherData.currently.temperature Current temperature
 * @param {String} weatherData.currently.summary short descriptor for weather conditions
 * @param {String} weatherData.currently.icon Part of icon filename
 * @param {Object[]} weatherData.daily Weather data for next 5 days
 * @param {String} weatherData.daily[].dayofweek 3-letter representation for day of the week
 * @param {String} weatherData.daily[].icon Part of icon filename
 * @param {Number} weatherData.daily[].tempMax Max temperature for day
 * @param {Number} weatherData.daily[].tempMin Min temperature for day
 * @param {JSX} Optional button component
 * @return {JSX} Presentational Component for WeatherCard
 */
const WeatherCard = ({ weatherData, actionButton }) => (
	<Card id="weather" title="Weather">
		{weatherData ? (
			<View>
				<View style={css.wc_topRowContainer}>
					<View style={css.wc_topLeftContainer}>
						<Text style={css.wc_tempText}>
							{ weatherData.currently.temperature }&deg; in San Diego
						</Text>
						<Text style={css.wc_summaryText}>
							{ weatherData.currently.summary }
						</Text>
					</View>
					<View style={css.wc_topRightContainer}>
						<Image
							style={css.wc_topIcon}
							source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + weatherData.currently.icon + '.png' }}
						/>
					</View>
				</View>

				<WeatherWeek weatherData={weatherData.daily} />
				{actionButton}
			</View>
		) : (
			<View style={css.wc_loadingContainer}>
				<ActivityIndicator size="large" />
			</View>
		)}
	</Card>
)

WeatherCard.propTypes = {
	weatherData: PropTypes.object,
	actionButton: PropTypes.element
}

export default WeatherCard
