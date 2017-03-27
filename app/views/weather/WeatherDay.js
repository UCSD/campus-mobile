import React from 'react';
import {
	View,
	Text,
	Image,
} from 'react-native';

const AppSettings = require('../../AppSettings');
const css = require('../../styles/css');

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
