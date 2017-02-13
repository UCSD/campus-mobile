import NearbyService from '../services/nearbyService';
import { convertMetersToMiles, getDistanceMilesStr, sortNearbyMarkers } from '../util/general';
import { getDistance } from '../util/map';

function saveSearch(term) {
	return {
		type: 'SAVE_SEARCH',
		term
	};
}

function fetchSearch(term, location) {
	return (dispatch, getState) => {
		NearbyService.FetchSearchResults(term)
			.then((results) => {
				if (location) {
					if (results) {
						// Sort results by closest
						_sortResults(location, results).then(() =>
						{
							dispatch({
								type: 'SET_SEARCH_RESULTS',
								results
							});
							return Promise.resolve();
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
					return Promise.resolve();
				}
			})
			.catch((error) => Promise.reject());
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
			console.log(results[i].title + " " + results[i].distance);

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
	fetchSearch,
};
