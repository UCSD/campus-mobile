import { put, takeLatest, call, select } from 'redux-saga/effects';
import logger from '../util/logger';
import DiningService from '../services/diningService';
import { DINING_API_TTL } from '../AppSettings';
import { convertMetersToMiles, getDistanceMilesStr, sortNearbyMarkers } from '../util/general';
import { getDistance } from '../util/map';

const getDining = (state) => (state.dining);

function* updateDining(action) {
	const { lastUpdated, data } = yield select(getDining);
	const { position } = action;

	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const diningTTL = DINING_API_TTL * 1000;

	if (timeDiff < diningTTL && data) {
		if (position) {
			const diningData = yield call(_sortDining, position, data);
			yield put({ type: 'SET_DINING', data: diningData });
		}
	} else {
		// Fetch for new data then sort
		const diningData = yield call(fetchDining, position);
		yield put({ type: 'SET_DINING', data: diningData });
		yield put({ type: 'SET_DINING_UPDATE', nowTime });
	}
}

function fetchDining(position) {
	return DiningService.FetchDining()
		.then((dining) => {
			if (position) {
				return _sortDining(position, dining);
			} else {
				return dining;
			}
		})
		.catch((error) => {
			logger.error(error);
		});
}

function _sortDining(position, diningData) {
	// Calc distance from dining locations
	return new Promise((resolve, reject) => {
		if (diningData) {
			for (let i = 0; diningData.length > i; i++) {
				const distance = getDistance(position.coords.latitude, position.coords.longitude, diningData[i].coords.lat, diningData[i].coords.lon);
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
		} else {
			reject(null);
		}
	});
}

function* diningSaga() {
	yield takeLatest('UPDATE_DINING', updateDining);
}

export default diningSaga;
