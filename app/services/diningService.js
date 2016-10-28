var AppSettings = require('../AppSettings');

var DiningService = {
	FetchDining: function() {
		return fetch(AppSettings.DINING_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	}
}

export default DiningService;