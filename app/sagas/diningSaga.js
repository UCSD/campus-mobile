import { put, takeLatest, call, select } from 'redux-saga/effects';
import logger from '../util/logger';
import DiningService from '../services/diningService';
import { DINING_API_TTL } from '../AppSettings';
import { convertMetersToMiles, getDistanceMilesStr, dynamicSort } from '../util/general';
import { getDistance } from '../util/map';

const getDining = (state) => (state.dining);

function* updateDining(action) {
	const { lastUpdated, data } = yield select(getDining);
	const { position } = action;

	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const diningTTL = DINING_API_TTL;
	let diningData;

	if (timeDiff < diningTTL && data) {
		diningData = yield call(_sortDining, data);
		if (position) {
			diningData = yield call(_setDiningDistance, position, diningData);
		}
	} else {
		// Fetch for new data then sort and set distance
		diningData = yield call(fetchDining, position);
	}
	if (diningData) {
		yield put({ type: 'SET_DINING', data: diningData });
	}
}

function fetchDining(position) {
	return DiningService.FetchDining()
		.then((dining) => {
			let diningData = _sortDining(dining);
			if (position) {
				diningData = _setDiningDistance(position, diningData);
			}
			return diningData;
		})
		.catch((error) => {
			logger.log(error);
		});
}

function _sortDining(diningData) {
	// Sort dining locations by name
	return new Promise((resolve, reject) => {
		if (Array.isArray(diningData)) {
			diningData.sort(dynamicSort('name'));
			resolve(diningData);
		} else {
			reject('Error _sortDining, diningData is not an array(' + diningData + ')');
		}
	});
}

function _setDiningDistance(position, diningData) {
	// Calc distance from dining locations
	return new Promise((resolve, reject) => {
		if (Array.isArray(diningData)) {
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
