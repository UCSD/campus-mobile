import React from 'react';
import {
	View,
	Text,
	Image,
} from 'react-native';

const AppSettings = require('../../AppSettings');
const css = require('../../styles/css');

export default class WeatherDay extends React.Component {
	render() {
		return (
			<View style={css.wc_botrow_col}>
				<Text style={css.wf_dayofweek}>{this.props.data.dayofweek}</Text>
				<Image style={css.wf_icon} source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + this.props.data.icon + '.png' }} />
				<Text style={css.wf_tempMax}>{this.props.data.tempMax}&deg;</Text>
				<Text style={css.wf_tempMin}>{this.props.data.tempMin}&deg;</Text>
			</View>
		);
	}
}
