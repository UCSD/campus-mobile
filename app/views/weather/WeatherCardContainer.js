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

/**
 * Container component for [WeatherCard]{@link WeatherCard}
 * @extends CardComponent
**/
class WeatherCardContainer extends CardComponent {
	/**
	 * Lifecycle function
	 * Logs to google analytics, attempts to update weather, start AppState listener
	 * @returns {void}
	**/
	componentDidMount() {
		logger.log('Card Mounted: Weather');
		this.props.updateWeather();
		AppState.addEventListener('change', this._handleAppStateChange);
	}

	/**
	 * Lifecycle function
	 * Removes AppState listener
	 * @returns {void}
	**/
	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange);
	}

	/**
	 * Callback function for AppState listener
	 * Tries to update weather when app is active
	 * @callback WeatherCardContainer~_handleAppStateChange
	 * @param {string} currentAppState - 'active', 'background', 'inactive'
	 * @returns {void}
	**/
	_handleAppStateChange = (currentAppState) => {
		if (currentAppState === 'active') {
			this.props.updateWeather();
		}
	}

	/**
	 * Lifecycle functions
	 * Renders WeatherCard, passing in data and goto
	 * @returns {JSX} WeatherCard component
	**/
	render() {
		return (
			<WeatherCard
				weatherData={this.props.weatherData}
				gotoSurfReport={() => Actions.SurfReport()}
			/>
		);
	}
}

const mapStateToProps = (state) => (
	{
		weatherData: state.weather.data,
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
