import logger from '../util/logger';
import { fetchMasterStopsNoRoutes, fetchMasterRoutes, fetchVehiclesByRoute } from '../services/shuttleService';
import { getDistance } from '../util/map';
import { SHUTTLE_MASTER_TTL } from '../AppSettings';

// const shuttleStopMap = require('../json/shuttle_stops_master_map_no_routes');

function updateMaster() {
	return (dispatch, getState) => {
		const { lastUpdated, routes, stops } = getState().shuttle;
		const nowTime = new Date().getTime();
		const timeDiff = nowTime - lastUpdated;
		const shuttleTTL = SHUTTLE_MASTER_TTL;

		if ((timeDiff < shuttleTTL) && (routes !== null) && (stops !== null)) {
			// Do nothing, don't need to update
		} else {
			// Fetch for new data
			fetchMasterStopsNoRoutes()
				.then((stopsData) => {
					fetchMasterRoutes()
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
							logger.log('Error fetching MasterRoutes: ' + error);
							return null;
						});
				})
				.catch((error) => {
					logger.log('Error fetching MasterStopsNoRoutes: ' + error);
					return null;
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
		fetchVehiclesByRoute(route)
			.then((vehicles) => {
				dispatch({
					type: 'SET_VEHICLES',
					route,
					vehicles
				});
			})
			.catch((error) => {
				logger.log('Error fetching Vehicles By Route: ' + error);
				return null;
			});
	};
}
/*
function updateClosestStop(location) {
	return (dispatch, getState) => {
		const shuttle = getState().shuttle;
		const stops = Object.assign({}, shuttle.stops);
		const currClosestStop = shuttle.closestStop;

		let closestDist = 1000000000;
		let closestStop;
		let closestSavedIndex = 0;

		if (shuttle.closestStop && shuttle.closestStop.savedIndex) {
			closestSavedIndex = shuttle.closestStop.savedIndex;
		}

		Object.keys(stops).forEach((stopID, index) => {
			const stop = Object.assign({}, stops[stopID]);
			const distanceFromStop = getDistance(location.coords.latitude, location.coords.longitude, stop.lat, stop.lon);

			if (distanceFromStop < closestDist) {
				closestStop = stop;
				closestDist = distanceFromStop;
			}
		});
		
		closestStop.closest = true;
		closestStop.savedIndex = closestSavedIndex;
		console.log('savedIndex' + closestSavedIndex);

		if (currClosestStop === null || currClosestStop.id !== closestStop.id) {
			dispatch({
				type: 'SET_CLOSEST_STOP',
				closestStop
			});

			dispatch({
				type: 'FETCH_ARRIVAL',
				stopID: closestStop.id
			});
		}
	};
}*/

/*
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
				logger.log('Error fetching ShuttleArrivalsByStop: ' + error);
				return null;
			});
	};
}
*/

module.exports = {
	toggleRoute,
	updateVehicles,
	// updateClosestStop,
	// updateArrivals,
	updateMaster,
};
