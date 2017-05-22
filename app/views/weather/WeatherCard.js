import React, { PropTypes } from 'react';
import {
	View,
	Text,
	Image,
	ActivityIndicator,
	StyleSheet,
} from 'react-native';

import Card from '../card/Card';

import WeatherWeek from './WeatherWeek';
import {
	COLOR_MGREY,
	COLOR_DGREY,
} from '../../styles/ColorConstants';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';
import AppSettings from '../../AppSettings';

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
 *
 * @todo Provide icon default using non-image urls?
 * @todo Get rid of PRM
 */
const WeatherCard = ({ weatherData, actionButton }) => (
	<Card id="weather" title="Weather">
		{weatherData ? (
			<View>
				<View style={styles.topRowContainer}>
					<View style={styles.topLeftContainer}>
						<Text style={styles.tempText}>
							{ weatherData.currently.temperature }&deg; in San Diego
						</Text>
						<Text style={styles.summaryText}>
							{ weatherData.currently.summary }
						</Text>
					</View>
					<View style={styles.topRightContainer}>
						<Image
							style={styles.topIcon}
							source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + weatherData.currently.icon + '.png' }}
						/>
					</View>
				</View>

				<WeatherWeek weatherData={weatherData.daily} />
				{actionButton}
			</View>
		) : (
			<View style={styles.loadingContainer}>
				<ActivityIndicator size="large" />
			</View>
		)}
	</Card>
);

WeatherCard.propTypes = {
	weatherData: PropTypes.object,
	actionButton: PropTypes.element
};

const styles = StyleSheet.create({
	topRowContainer: { flexDirection: 'row', borderBottomWidth: 1, borderColor: COLOR_MGREY, justifyContent: 'center', alignItems: 'center', width: MAX_CARD_WIDTH, paddingHorizontal: 14 },
	topLeftContainer: { flex: 4 },
	tempText: { fontSize: 22, fontWeight: '300' },
	summaryText: { fontSize: 15, color: COLOR_DGREY, paddingTop: 10, fontWeight: '300' },
	topRightContainer: { flex: 1 },
	topIcon: { width: 68, height: 68 },
	loadingContainer: { alignItems: 'center', justifyContent: 'center', width: MAX_CARD_WIDTH },
});

export default WeatherCard;
