import React from 'react';
import {
	AppState
} from 'react-native';

import { Actions } from 'react-native-router-flux';
import { connect } from 'react-redux';

import CardComponent from '../card/CardComponent';

import { updateWeather } from '../../actions/weather';

import WeatherCard from './WeatherCard';

import logger from '../../util/logger';

import AppSettings from '../../AppSettings';

class WeatherCardContainer extends CardComponent {
	componentDidMount() {
		logger.log('Card Mounted: Weather');

		this.props.updateWeather();

		AppState.addEventListener('change', this._handleAppStateChange);
	}

	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange);
	}

	_handleAppStateChange = (currentAppState) => {
		this.setState({ currentAppState });

		// check TTL and refresh weather data if needed
		if (currentAppState === 'active') {
			const nowTime = new Date.getTime();
			const timeDiff = nowTime - this.props.weatherLastUpdated;
			const weatherTTL = AppSettings.WEATHER_API_TTL * 1000; // convert secs to ms

			if (timeDiff > weatherTTL) {
				this.props.updateWeather();
			}
		}
	}

	render() {
		return (<WeatherCard
			weatherData={this.props.weatherData}
			gotoSurfReport={this.gotoSurfReport}
		/>);
	}

	gotoSurfReport() {
		Actions.SurfReport();
	}
}

const mapStateToProps = (state) => (
	{
		weatherData: state.weather.data,
		weatherLastUpdated: state.weather.lastUpdated,
	}
);

const mapDispatchToProps = (dispatch) => (
	{
		updateWeather: () => {
			dispatch(updateWeather());
		}
	}
);

const ActualWeatherCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(WeatherCardContainer);

export default ActualWeatherCard;
