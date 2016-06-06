'use strict';

import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView
} from 'react-native';

var css = require('../styles/css');
var logger = require('../util/logger');


var WeatherForecast = React.createClass({

	getInitialState: function() {
		return {
			weatherData: null,
		}
	},

	componentWillMount: function() {
		logger.custom('View Loaded: Event Detail');
	},

	componentDidMount: function() {
		var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		this.setState({
			weatherData: dsFull.cloneWithRows(this.props.route.weatherData.daily.data),
		});
	},
	
	render: function() {
		return this.renderScene();
	},

	renderScene: function() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>

					{this.state.weatherData ? (
						<ListView dataSource={this.state.weatherData} renderRow={ this.renderForecastDay } style={css.wf_listview} />
					) : (
						<View style={css.flexcenter3}>
							<Image style={css.shuttlecard_loading} source={{ uri: "https://s3-us-west-2.amazonaws.com/ucsd-images/ajax-loader.gif" }} />
						</View>
					)}

				</ScrollView>
			</View>
		);
	},

	renderForecastDay: function(data) {

		var wf_unix_timestamp = data.time;
		var wf_date = new Date(wf_unix_timestamp * 1000);
		var wf_days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
		var wf_months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
		var wf_day = wf_date.getDay();
		var wf_month = wf_date.getMonth();
		var wf_dayofmonth = wf_date.getDate();
		var wf_dayofweek = wf_days[wf_day];
		var wf_month = wf_months[wf_month];

		logger.log('data.summary: ' + data.summary);

		var temperature_F_max = Math.round(data.temperatureMax);
		var temperature_F_min = Math.round(data.temperatureMin);

		var humidity_str = Math.round(data.humidity * 100) + '%';

		return (
			<View style={css.wf_day_row}>
				<View style={css.wf_day_date_container}>
					<Text style={css.wf_dayofweek}>{wf_dayofweek}</Text>
					<Text style={css.wf_dayandmonth}>{wf_dayofmonth} {wf_month}</Text>
				</View>

				<View style={css.wf_day_icon_container}>
					<Image style={css.wf_day_icon} source={{ uri: "https://act.ucsd.edu/cwp/homepage/weather-icons/480/" + data.icon + ".png"}} />
				</View>

				<View style={css.wf_day_details_container}>
					<Text style={css.wf_day_details_temperature}>{temperature_F_max}&deg;  <Text style={css.wf_day_details_temperature_low}>{temperature_F_min}&deg;</Text> </Text>
					<Text style={css.wf_day_details_summary} numberOfLines={2}>{data.summary}</Text>
					<Text style={css.wf_day_details_humidity}>Humidity: {humidity_str}</Text>
				</View>
			</View>
		);
	},


});

module.exports = WeatherForecast;