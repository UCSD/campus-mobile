import React from 'react';
import { Actions } from 'react-native-router-flux';
import { connect } from 'react-redux';

import SurfButton from './SurfButton';
import WeatherCard from './WeatherCard';
import logger from '../../util/logger';

/**
 * Container component for [WeatherCard]{@link WeatherCard}
**/
const WeatherCardContainer = ({ weatherData }) => {
	logger.ga('Card Mounted: Weather');
	return (
		<WeatherCard
			weatherData={weatherData}
			actionButton={<SurfButton />}
		/>
	);
};

const mapStateToProps = (state) => (
	{
		weatherData: state.weather.data,
	}
);

const ActualWeatherCard = connect(
	mapStateToProps
)(WeatherCardContainer);

export default ActualWeatherCard;
