const AppSettings = require('../AppSettings');

var DiningService = {
	FetchDining() {
		return fetch(AppSettings.DINING_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json())
		.then((data) => {
			if (data.errorMessage) throw (data.errorMessage);
			return data;
		});
	}
};

export default DiningService;
