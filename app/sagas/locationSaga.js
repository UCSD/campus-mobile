import { delay } from 'redux-saga';
import { put, takeLatest, call, select } from 'redux-saga/effects';
import Permissions from 'react-native-permissions';
import * as LocationService from '../services/locationService';
import { getDistance } from '../util/map';

const getLocation = (state) => (state.location);
const getShuttle = (state) => (state.shuttle);

function* watchLocation() {
	while (true) {
		try {
			const location = yield select(getLocation);

			if (location.permission === 'authorized' && location.position && location.position.coords) {
				const position = yield call(LocationService.getPosition);
				yield put({ type: 'SET_POSITION', position });
				const closestStop = yield call(getClosestStop, position); // CHANGE TO SAGA
				yield put({ type: 'SET_CLOSEST_STOP', closestStop });
				yield put({ type: 'UPDATE_DINING', position });
			} else {
				const perm = yield call(getPermission, 'location');
				yield put({ type: 'SET_PERMISSION', permission: perm });
			}
		} catch (err) {
			console.log('Error: watchLocation: ' + err);
		}
		yield delay(5000); // wait 5s
	}
}

function getPermission(type) {
	return Permissions.requestPermission(type);
}

// Move to shuttleSaga?
function* getClosestStop(location) {
	const shuttle = yield select(getShuttle);
	const stops = shuttle.stops;
	const currClosestStop = shuttle.closestStop;

	let closestDist = 1000000000;
	let closestStop;
	let closestSavedIndex = 0;

	if (currClosestStop && currClosestStop.savedIndex) {
		closestSavedIndex = currClosestStop.savedIndex;
	}

	Object.keys(stops).forEach((stopID, index) => {
		const stop = stops[stopID];
		const distanceFromStop = getDistance(location.coords.latitude, location.coords.longitude, stop.lat, stop.lon);

		if (distanceFromStop < closestDist) {
			closestStop = Object.assign({}, stop);
			closestDist = distanceFromStop;
		}
	});
	closestStop.closest = true;
	closestStop.savedIndex = closestSavedIndex;

	return closestStop;
}

function* locationSaga() {
	yield call(watchLocation);
}

export default locationSaga;
