import logger from '../util/logger';
import WeatherService from '../services/weatherService';
import { WEATHER_API_TTL } from '../AppSettings';

function updateWeather() {
	return (dispatch, getState) => {
		const { lastUpdated, data } = getState().weather;
		const nowTime = new Date().getTime();
		const timeDiff = nowTime - lastUpdated;
		const weatherTTL = WEATHER_API_TTL;

		if (timeDiff < weatherTTL && data) {
			// Do nothing, no need to fetch new data
		} else {
			WeatherService.FetchWeather()
			.then((weather) => {
				dispatch({
					type: 'SET_WEATHER',
					weather
				});
			})
			.catch((error) => {
				logger.log('Error fetching Weather: ' + error);
				return null;
			});
		}
	};
}

module.exports = {
	updateWeather,
};
