import logger from '../util/logger';
import ShuttleService from '../services/shuttleService';
import { getDistance } from '../util/map';

const shuttleStopMap = require('../json/shuttle_stops_master_map_no_routes');

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

function updateClosestStop(location) {
	let closestDist = 1000000000;
	let closestStop = -1;

	Object.keys(shuttleStopMap).forEach((stopID, index) => {
		const stop = shuttleStopMap[stopID];
		const distanceFromStop = getDistance(location.coords.latitude, location.coords.longitude, stop.lat, stop.lon);

		if (distanceFromStop < closestDist) {
			closestStop = stopID;
			closestDist = distanceFromStop;
		}
	});

	return (dispatch) => {
		dispatch({
			type: 'SET_CLOSEST_STOP',
			closestStop
		});
		dispatch(updateArrivals(closestStop));
	};
}

function updateArrivals(stop) {
	return (dispatch) => {
		ShuttleService.FetchShuttleArrivalsByStop(stop)
			.then((arrivalData) => {
				// Sort Arrival data by arrival time, should be on lambda
				arrivalData.sort((a, b) => {
					const aSecs = a.secondsToArrival;
					const bSecs = b.secondsToArrival;

					if ( aSecs < bSecs ) return -1;
					if ( aSecs > bSecs) return 1;
					return 0;
				});

				dispatch({
					type: 'SET_ARRIVALS',
					stop,
					arrivalData
				});
			})
			.catch((error) => {
				logger.error(error);
			});
	};
}

module.exports = {
	toggleRoute,
	updateVehicles,
	updateClosestStop,
	updateArrivals,
};
