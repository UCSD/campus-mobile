import React from 'react';
import {
	View,
	Text,
	Image,
	StyleSheet
} from 'react-native';

import {
	COLOR_BLACK,
	COLOR_DGREY,
} from '../../styles/ColorConstants';
import AppSettings from '../../AppSettings';

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
	<View style={styles.dayContainer}>
		<Text style={styles.dayText}>
			{data.dayofweek}
		</Text>
		<Image
			style={styles.icon}
			source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + data.icon + '.png' }}
		/>
		<Text style={styles.maxText}>
			{data.tempMax}&deg;
		</Text>
		<Text style={styles.minText}>
			{data.tempMin}&deg;
		</Text>
	</View>
);

const styles = StyleSheet.create({
	dayContainer: { flex: 1, flexDirection: 'column', justifyContent: 'center', alignItems: 'center' },
	dayText: { fontSize: 14, fontWeight: '300', color: COLOR_BLACK, paddingBottom: 10 },
	icon: { height: 33, width: 33 },
	minText: { fontSize: 14, fontWeight: '300', color: COLOR_DGREY, paddingTop: 10 },
	maxText: { fontSize: 14, fontWeight: '300', color: COLOR_BLACK, paddingTop: 10 },
});

export default WeatherDay;
