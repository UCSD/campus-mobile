import {
	SHUTTLE_ROUTES_MASTER,
	SHUTTLE_STOPS_MASTER_NO_ROUTES,
	SHUTTLE_STOPS_API_URL,
	SHUTTLE_VEHICLES_API_URL
} from '../AppSettings';

export function fetchShuttleArrivalsByStop(stopID) {
	const stopURL = SHUTTLE_STOPS_API_URL + stopID + '/arrivals';
	return fetch(stopURL, {
		method: 'GET',
		headers: {
			'Accept' : 'application/json',
			'Cache-Control': 'no-cache'
		}
	})
	.then((response) => response.json())
	.catch((err) => {
		console.log('Error fetching arrivals for stop ' + stopID + ' ' + err);
		return null;
	});
}

export function fetchVehiclesByRoute(routeID) {
	return fetch(SHUTTLE_VEHICLES_API_URL + routeID, {
		method: 'GET',
		headers: {
			'Accept': 'application/json',
			'Cache-Control': 'no-cache'
		}
	})
	.then((response) => response.json());
}

export function fetchMasterStopsNoRoutes() {
	return fetch(SHUTTLE_STOPS_MASTER_NO_ROUTES, {
		headers: {
			'Cache-Control': 'no-cache'
		}
	})
	.then((response) => response.json());
}

export function fetchMasterRoutes() {
	return fetch(SHUTTLE_ROUTES_MASTER, {
		headers: {
			'Cache-Control': 'no-cache'
		}
	})
	.then((response) => response.json());
}
