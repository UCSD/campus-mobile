import {
	SHUTTLE_ROUTES_MASTER,
	SHUTTLE_STOPS_MASTER_NO_ROUTES
} from '../AppSettings';

const stopURL = 'https://ies4wyrlx9.execute-api.us-west-2.amazonaws.com/prod/stops/';
const vehicleURL = 'https://87t4myy3wj.execute-api.us-west-2.amazonaws.com/dev?route=';

const ShuttleService = {
	FetchShuttleArrivalsByStop(stopID) {
		const SHUTTLE_STOPS_API_URL = stopURL + stopID + '/arrivals';
		return fetch(SHUTTLE_STOPS_API_URL, {
			method: 'GET',
			headers: {
				'Accept' : 'application/json',
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	},
	FetchVehiclesByRoute(routeID) {
		return fetch(vehicleURL + routeID, {
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
