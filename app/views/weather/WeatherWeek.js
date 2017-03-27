import React from 'react';
import {
	View,
} from 'react-native';

import WeatherDay from './WeatherDay';

const css = require('../../styles/css');

const WeatherWeek = ({ weatherData }) => (
	<View style={css.wc_botrow}>
		{weatherData.daily.data.map((val,index) =>
			<WeatherDay key={index} data={val} />
		)}
	</View>
);

export default WeatherWeek;
