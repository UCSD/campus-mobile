import logger from '../util/logger';
import ShuttleService from '../services/shuttleService';

function toggleRoute(route) {
	return {
		type: 'TOGGLE_ROUTE',
		route
	};
}

function updateVehicles(route) {
	return (dispatch) => {
		ShuttleService.FetchVehiclesByRoute(route)
			.then((vehicles) => {
				dispatch({
					type: 'SET_VEHICLES',
					route,
					vehicles
				});
			})
			.catch((error) => {
				logger.error(error);
			});
	};
}

function fetchStop(stop) {
	return {
		type: 'FETCH_STOP',
		stop
	};
}

module.exports = {
	toggleRoute,
	updateVehicles,
	fetchStop
};
