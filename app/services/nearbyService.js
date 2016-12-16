const AppSettings = require('../AppSettings');

const NearbyService = {
	FetchSearchResults(search) {
		return fetch(AppSettings.MAP_SEARCH_API_URL + search, {
			method: 'GET',
			headers: {
				'Accept' : 'application/json',
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	}
};

export default NearbyService;
