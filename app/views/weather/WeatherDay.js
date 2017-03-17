import React from 'react';
import {
	View,
	Text,
	Image,
} from 'react-native';

import AppSettings from '../../AppSettings';
import css from '../../styles/css';

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
	<View style={css.wc_botrow_col}>
		<Text style={css.wf_dayofweek}>
			{data.dayofweek}
		</Text>
		<Image
			style={css.wf_icon}
			source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + data.icon + '.png' }}
		/>
		<Text style={css.wf_tempMax}>
			{data.tempMax}&deg;
		</Text>
		<Text style={css.wf_tempMin}>
			{data.tempMin}&deg;
		</Text>
	</View>
);

export default WeatherDay;
