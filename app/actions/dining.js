import logger from '../util/logger';
import DiningService from '../services/diningService';

function updateDining(location) {
	return (dispatch) => {
		DiningService.FetchDining(location)
			.then((dining) => {
				dispatch({
					type: 'SET_DINING',
					dining
				});
			})
			.catch((error) => {
				logger.error(error);
			});
	};
}

module.exports = {
	updateDining
};
