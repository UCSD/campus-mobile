'use strict'

import React from 'react'
import {
	View,
	ListView,
	Text,
	Image,
	TouchableHighlight,
	Animated,
	ActivityIndicator,
} from 'react-native';

import Card from '../card/Card'
import CardComponent from '../card/CardComponent'

import WeatherWeek from './WeatherWeek';
import SurfReport from './SurfReport';
import WeatherService from '../../services/weatherService';

var css = require('../../styles/css');
var logger = require('../../util/logger');
var general = require('../../util/general');
var AppSettings = require('../../AppSettings');

export default class WeatherCard extends CardComponent {
  constructor(props) {
	super(props);
	this.state = {
	  weatherData: null,
	  weatherDataLoaded: false,
	}
  }

	componentDidMount() {
		this.refresh();
	}

  fetchWeatherData() {

	WeatherService.FetchWeather()
	  .then((responseData) => {

		responseData.currently.temperature = Math.round(responseData.currently.temperature);
		responseData.daily.data = responseData.daily.data.slice(0,5);

		for (var i = 0; responseData.daily.data.length > i; i++) {
		  var data = responseData.daily.data[i];
		  var wf_date = new Date(data.time * 1000);
		  var wf_days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
		  var wf_day = wf_date.getDay();

		  data.dayofweek = wf_days[wf_day];
		  data.tempMax = Math.round(data.temperatureMax);
		  data.tempMin = Math.round(data.temperatureMin);
		}

		this.setState({
		  weatherData: responseData,
		  weatherDataLoaded: true,
		});
	  })
	  .catch((error) => {
		logger.custom('ERR: fetchWeatherData: ' + error);
	  })
	  .done();
  }

  // TODO: should probably be handled by surf screen
  fetchSurfData() {

	WeatherService.FetchSurf()
	  .then((responseData) => {
		this.setState({
		  surfData: responseData,
		  surfDataLoaded: true,
		});
	  })
	  .catch((error) => {
		logger.custom('ERR: fetchSurfData: ' + error);
	  })
	  .done();
  }

  getCurrentSurfData() {
	if (this.state.surfDataLoaded) {
	  var surfData = this.state.surfData[0].title.replace(/.* \: /g, '').replace(/ft.*/g, '').replace(/^\./g, '').replace(/^ /g, '').replace(/ $/g, '').replace(/Surf\: /g, '').trim() + "'";
	  if (surfData.length <= 6) {
		return (surfData);
	  } else if (surfData.indexOf('none') >= 0) {
		return '1-2\'';
	  } else {
		return ;
	  }
	} else {
	  return;
	}
  }

  refresh() {
	this.fetchWeatherData();
	this.fetchSurfData();
	}

  gotoSurfReport() {
	this.props.navigator.push({ id: 'SurfReport', component: SurfReport, title: 'Surf Report', surfData: this.state.surfData });
  }

	render() {
		return (
		<Card title='Weather'>
			{this.state.weatherDataLoaded ? (
				<View style={css.wc_main}>
					<View style={css.wc_toprow}>
						<View style={css.wc_toprow_left}>
							<Text style={css.wc_current_temp}>{ this.state.weatherData.currently.temperature }&deg; in San Diego</Text>
							<Text style={css.wc_current_summary}>{ this.state.weatherData.currently.summary }</Text>
						</View>
						<View style={css.wc_toprow_right}>
							<Image style={css.wc_toprow_icon} source={{ uri: AppSettings.WEATHER_ICON_BASE_URL + this.state.weatherData.currently.icon + '.png' }} />
						</View>
					</View>

					<WeatherWeek weatherData={this.state.weatherData} />

					<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoSurfReport() }>
						<View style={css.weathercard_border}>
							<Text style={css.wc_surfreport_more}>Surf Report &raquo;</Text>
						</View>
					</TouchableHighlight>
				</View>
			) : (
				<View style={[css.cardcenter, css.weatherccard_loading_height]}>
					<ActivityIndicator style={css.shuttle_card_aa} size="large" />
				</View>
			)}
		</Card>
		);
	}
}