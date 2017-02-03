import logger from '../util/logger';
import WeatherService from '../services/weatherService';

function updateSurf() {
	return (dispatch) => {
		WeatherService.FetchSurf()
			.then((surf) => {
				dispatch({
					type: 'SET_SURF',
					surf
				});
			})
			.catch((error) => {
				logger.error(error);
			});
	};
}

module.exports = {
	updateSurf,
};
