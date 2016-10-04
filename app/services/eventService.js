var AppSettings = 		require('../AppSettings');


var EventService = {

	FetchEvents: function() {
		return fetch(AppSettings.EVENTS_API_URL, {
			method: 'get',
			dataType: 'json',
			headers: {
			'Accept': 'application/json',
			'Content-Type': 'application/json'
			}
		})
		.then((response) => response.json())
		.then((responseData) => responseData);
	}

}

export default EventService;
