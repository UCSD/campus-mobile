const AppSettings = require('../AppSettings');

const MAPLINK_API_URL = 'http://act.ucsd.edu/maps/textsearch.json?q=';
const MAPLINK_API_URL_END = '&region=0';

const NearbyService = {
	FetchSearchResults(search) {
		const API_URL = MAPLINK_API_URL + search + MAPLINK_API_URL_END;
		return fetch(API_URL, {
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
