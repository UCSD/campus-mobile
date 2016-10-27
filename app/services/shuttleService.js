var AppSettings = require('../AppSettings');

var ShuttleService = {
	FetchShuttleArrivalsByStop: function(stopID) {
		const SHUTTLE_STOPS_API_URL = AppSettings.SHUTTLE_STOPS_API_URL + stopID + '/arrivals';
		return fetch(SHUTTLE_STOPS_API_URL, {
			method: 'GET',
			headers: {
				'Accept' : 'application/json',
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	}
}

export default ShuttleService;