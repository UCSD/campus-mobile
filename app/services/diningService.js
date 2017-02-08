import { convertMetersToMiles, getDistanceMilesStr, sortNearbyMarkers } from '../util/general';
import { getDistance } from '../util/map';

const AppSettings = require('../AppSettings');

const DiningService = {
	FetchDining(location) {
		return fetch(AppSettings.DINING_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => (response.json()))
		.then((data) => {
			if (data.errorMessage) {
				throw (data.errorMessage);
			} else if (location) {
				// Sort by closest, should be on lambda?
				// Calc distance from dining locations
				const diningData = data.GetDiningInfoResult;

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

				return diningData;
			}
			else {
				return data.GetDiningInfoResult;
			}
		});
	}
};

export default DiningService;
