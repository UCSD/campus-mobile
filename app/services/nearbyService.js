import logger from '../util/logger';
import { MAP_SEARCH_API_URL } from '../AppSettings';

const NearbyService = {
	FetchSearchResults(search) {
		return fetch(MAP_SEARCH_API_URL + search, {
			method: 'GET',
			headers: {
				'Accept' : 'application/json',
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json())
		.then((responseJSON) => responseJSON)
		.catch((error) => logger.log(error));
	}
};

export default NearbyService;
