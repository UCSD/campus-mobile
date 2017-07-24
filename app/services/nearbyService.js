import logger from '../util/logger';
import { MAP_SEARCH_API_URL } from '../AppSettings';
import { convertMetersToMiles, getDistanceMilesStr, sortNearbyMarkers } from '../util/general';
import { getDistance } from '../util/map';

export default function fetchSearchResults(search, location) {
	return fetch(MAP_SEARCH_API_URL + search, {
		method: 'GET',
		headers: {
			'Accept' : 'application/json',
			'Cache-Control': 'no-cache'
		}
	})
	.then((response) => response.json())
	.then((results) => _sortResults(location, results))
	.catch((error) => logger.log(error));
}

function _sortResults(location, results) {
	if (location && Array.isArray(results)) {
		// Calc distance from dining locations
		return new Promise((resolve, reject) => {
			for (let i = 0; results.length > i; i++) {
				const distance = getDistance(location.coords.latitude, location.coords.longitude, results[i].mkrLat, results[i].mkrLong);
				if (distance) {
					results[i].distance = distance;
				} else {
					results[i].distance = 100000000;
				}

				results[i].distanceMiles = convertMetersToMiles(distance);
				results[i].distanceMilesStr = getDistanceMilesStr(results[i].distanceMiles);
			}
			// Sort dining locations by distance
			results.sort(sortNearbyMarkers);
			resolve(results);
		});
	} else {
		return results;
	}
}
