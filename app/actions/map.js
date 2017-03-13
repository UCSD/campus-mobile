import NearbyService from '../services/nearbyService';
import { convertMetersToMiles, getDistanceMilesStr, sortNearbyMarkers } from '../util/general';
import logger from '../util/logger';
import { getDistance } from '../util/map';

function saveSearch(term) {
	return {
		type: 'SAVE_SEARCH',
		term
	};
}

function clearSearch() {
	return ({
		type: 'CLEAR_SEARCH_RESULTS'
	});
}

function fetchSearch(term, location) {
	return (dispatch, getState) => {
		NearbyService.FetchSearchResults(term)
			.then((results) => {
				if (results && Object.keys(results).length !== 0) {
					if (location) {
						if (results) {
							// Sort results by closest
							_sortResults(location, results).then(() =>
							{
								dispatch({
									type: 'SET_SEARCH_RESULTS',
									results
								});
							});
						}
					} else {
						dispatch({
							type: 'SET_SEARCH_RESULTS',
							results
						});

						// Save search to history if it was useful
						if (results) {
							dispatch(saveSearch(term));
						}
					}
				}
				else {
					dispatch({
						type: 'SET_SEARCH_RESULTS',
						results: null
					});
				}
			})
			.catch((error) => logger.log('Error fetching search for: ' + term));
	};
}

function _sortResults(location, results) {
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
}

module.exports = {
	saveSearch,
	clearSearch,
	fetchSearch,
};
