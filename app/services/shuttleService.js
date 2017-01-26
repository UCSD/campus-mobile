const AppSettings = require('../AppSettings');

const vehicleURL = 'https://87t4myy3wj.execute-api.us-west-2.amazonaws.com/dev?route=';

const ShuttleService = {
	FetchShuttleArrivalsByStop(stopID) {
		const SHUTTLE_STOPS_API_URL = AppSettings.SHUTTLE_STOPS_API_URL + stopID + '/arrivals';
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
	}
};

export default ShuttleService;
