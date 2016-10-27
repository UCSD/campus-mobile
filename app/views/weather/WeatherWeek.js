import React from 'react';
import {
	View,
} from 'react-native';

import WeatherDay from './WeatherDay';

const css = require('../../styles/css');

export default class WeatherWeek extends React.Component {
	render() {
		return (
			<View style={css.wc_botrow}>
				{this.props.weatherData.daily.data.map((val,index) =>
					<WeatherDay key={index} data={val} />
				)}
			</View>
		);
	}
}
