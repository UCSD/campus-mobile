import logger from '../util/logger';
import DiningService from '../services/diningService';
import { DINING_API_TTL } from '../AppSettings';
import { convertMetersToMiles, getDistanceMilesStr, sortNearbyMarkers } from '../util/general';
import { getDistance } from '../util/map';

function updateDining(location) {
	return (dispatch, getState) => {
		const { lastUpdated, data } = getState().dining;
		const nowTime = new Date().getTime();
		const timeDiff = nowTime - lastUpdated;
		const diningTTL = DINING_API_TTL * 1000;

		if (timeDiff < diningTTL && data) {
			// Sort with current data
			_sortDining(location, getState().dining.data).then(
				(sortedData) => {
					dispatch({
						type: 'SET_DINING',
						sortedData
					});
				}
			);
		} else {
			// Fetch for new data then sort
			DiningService.FetchDining()
				.then((dining) => {
					dispatch({
						type: 'SET_DINING_UPDATE',
						nowTime
					});
					_sortDining(location, dining).then(
						(sortedData) => {
							dispatch({
								type: 'SET_DINING',
								sortedData
							});
						}
					);
				})
				.catch((error) => {
					logger.error(error);
				});
		}
	};
}

function _sortDining(location, diningData) {
	// Calc distance from dining locations
	return new Promise((resolve, reject) => {
		for (let i = 0; diningData.length > i; i++) {
			const distance = getDistance(location.coords.latitude, location.coords.longitude, diningData[i].coords.lat, diningData[i].coords.lon);
			if (distance) {
				diningData[i].distance = distance;
			} else {
				diningData[i].distance = 100000000;
			}

			diningData[i].distanceMiles = convertMetersToMiles(distance);
			diningData[i].distanceMilesStr = getDistanceMilesStr(diningData[i].distanceMiles);
		}

		// Sort dining locations by distance
		diningData.sort(sortNearbyMarkers);
		resolve(diningData);
	});
}

module.exports = {
	updateDining
};
