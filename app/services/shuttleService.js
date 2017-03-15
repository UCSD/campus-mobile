import {
	SHUTTLE_ROUTES_MASTER,
	SHUTTLE_STOPS_MASTER_NO_ROUTES,
	SHUTTLE_STOPS_API_URL,
	SHUTTLE_VEHICLES_API_URL
} from '../AppSettings';

const ShuttleService = {
	FetchShuttleArrivalsByStop(stopID) {
		const stopURL = SHUTTLE_STOPS_API_URL + stopID + '/arrivals';
		return fetch(stopURL, {
			method: 'GET',
			headers: {
				'Accept' : 'application/json',
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	},
	FetchVehiclesByRoute(routeID) {
		return fetch(SHUTTLE_VEHICLES_API_URL + routeID, {
			method: 'GET',
			headers: {
				'Accept': 'application/json',
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	},
	FetchMasterStopsNoRoutes() {
		return fetch(SHUTTLE_STOPS_MASTER_NO_ROUTES, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	},
	FetchMasterRoutes() {
		return fetch(SHUTTLE_ROUTES_MASTER, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	}
};

export default ShuttleService;
