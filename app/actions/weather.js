import logger from '../util/logger';
import WeatherService from '../services/weatherService';

function updateWeather() {
	return (dispatch) => {
		WeatherService.FetchWeather()
			.then((weather) => {
				dispatch({
					type: 'SET_WEATHER',
					weather
				});
			})
			.catch((error) => {
				logger.error(error);
			});
	};
}

module.exports = {
	updateWeather,
};
