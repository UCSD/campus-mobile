import logger from '../util/logger';
import ShuttleService from '../services/shuttleService';
import { getDistance } from '../util/map';
import { SHUTTLE_MASTER_TTL } from '../AppSettings';

// const shuttleStopMap = require('../json/shuttle_stops_master_map_no_routes');

function updateMaster() {
	return (dispatch, getState) => {
		const { lastUpdated, routes, stops } = getState().shuttle;
		const nowTime = new Date().getTime();
		const timeDiff = nowTime - lastUpdated;
		const shuttleTTL = SHUTTLE_MASTER_TTL * 1000;

		if ((timeDiff < shuttleTTL) && (routes !== null) && (stops !== null)) {
			// Do nothing, don't need to update
		} else {
			// Fetch for new data
			ShuttleService.FetchMasterStopsNoRoutes()
				.then((stopsData) => {
					ShuttleService.FetchMasterRoutes()
						.then((routesData) => {
							// Set toggles
							const initialToggles = {};
							Object.keys(routesData).forEach((key, index) => {
								initialToggles[key] = false;
							});

							dispatch({
								type: 'SET_SHUTTLE_MASTER',
								stops: stopsData,
								routes: routesData,
								toggles: initialToggles,
								nowTime
							});
						})
						.catch((error) => {
							logger.error(error);
						});
				})
				.catch((error) => {
					logger.error(error);
				});
		}
	};
}

function toggleRoute(route) {
	return (dispatch, getState) => {
		const { toggles, stops, routes } = getState().shuttle;

		Object.keys(toggles).forEach((element) => {
			// Toggle off any non-selected route
			if (Number(element) !== Number(route)) {
				if (toggles[element] === true) {
					// Remove route from every stop
					Object.keys(routes[element].stops).forEach((key2, index2) => {
						if (stops[key2]) {
							delete stops[key2].routes[element];
						}
					});
				}
				toggles[element] = false;
			} else {
				Object.keys(routes[element].stops).forEach((key2, index2) => {
					if (stops[key2]) {
						stops[key2].routes[element] = routes[element];
					}
				});

				toggles[element] = true;
			}
		});

		dispatch({
			type: 'TOGGLE_ROUTE',
			toggles,
			route,
			stops
		});
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
	return (dispatch, getState) => {
		const { stops } = getState().shuttle;

		let closestDist = 1000000000;
		let closestStop = -1;

		Object.keys(stops).forEach((stopID, index) => {
			const stop = stops[stopID];
			const distanceFromStop = getDistance(location.coords.latitude, location.coords.longitude, stop.lat, stop.lon);

			if (distanceFromStop < closestDist) {
				closestStop = stopID;
				closestDist = distanceFromStop;
			}
		});

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
				if (arrivalData && arrivalData.length !== 0) {
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
				}
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
	updateMaster,
};
