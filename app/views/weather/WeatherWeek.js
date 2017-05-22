import React, { PropTypes } from 'react';
import {
	View,
	StyleSheet
} from 'react-native';

import WeatherDay from './WeatherDay';

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
	<View style={styles.weekContainer}>
		{weatherData.data.map((val,index) =>
			<WeatherDay key={index} data={val} />
		)}
	</View>
);

WeatherWeek.propTypes = {
	weatherData: PropTypes.object,
};

const styles = StyleSheet.create({
	weekContainer: { flexDirection: 'row', padding: 20 },
});

export default WeatherWeek;
