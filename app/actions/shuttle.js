import logger from '../util/logger';
import ShuttleService from '../services/shuttleService';
import { getDistance } from '../util/map';

const shuttle_routes = require('../json/shuttle_routes_master.json');

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
	const closestDist = 1000000000;
	let closestStop = -1;

	for (let i = 0; shuttle_routes.length > i; i++) {
		const shuttleRoute = shuttle_routes[i];

		for (let n = 0; shuttleRoute.stops.length > n; n++) {
			const shuttleRouteStop = shuttleRoute.stops[n];
			const distanceFromStop = getDistance(location.coords.latitude, location.coords.longitude, shuttleRouteStop.lat, shuttleRouteStop.lon);

			// Rewrite this later using sortRef from shuttleDetail
			if (distanceFromStop < closestDist) {
				closestStop = shuttleRouteStop.id;
				/*
				this.shuttleClosestStops[0].stopID = shuttleRouteStop.id;
				this.shuttleClosestStops[0].stopName = shuttleRouteStop.name;
				this.shuttleClosestStops[0].dist = distanceFromStop;
				this.shuttleClosestStops[0].stopLat = shuttleRouteStop.lat;
				this.shuttleClosestStops[0].stopLon = shuttleRouteStop.lon;*/
			} /* else if (distanceFromStop < this.shuttleClosestStops[1].dist && this.shuttleClosestStops[0].stopID !== shuttleRouteStop.id) {
				this.shuttleClosestStops[1].stopID = shuttleRouteStop.id;
				this.shuttleClosestStops[1].stopName = shuttleRouteStop.name;
				this.shuttleClosestStops[1].dist = distanceFromStop;
				this.shuttleClosestStops[1].stopLat = shuttleRouteStop.lat;
				this.shuttleClosestStops[1].stopLon = shuttleRouteStop.lon;
			}*/
		}
	}
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
