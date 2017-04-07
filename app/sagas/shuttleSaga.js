import { delay } from 'redux-saga';
import { call, fork, put, select, takeLatest } from 'redux-saga/effects';

import { fetchShuttleArrivalsByStop } from '../services/shuttleService';

const getShuttle = (state) => (state.shuttle);

function* addStop(action) {
	const shuttle = yield select(getShuttle);
	const savedStops = shuttle.savedStops.slice(); // copy array
	const stops = Object.assign({}, shuttle.stops);
	const closestStop = Object.assign({}, shuttle.closestStop);
	let contains = false;

	// Make sure stop hasn't already been saved
	for (let i = 0;  i < savedStops.length; ++i) {
		if (savedStops[i].id === action.stopID) {
			contains = true;
			break;
		}
	}
	if (!contains) {
		savedStops.unshift(stops[action.stopID]);
	}

	// Updated closestStop index
	++closestStop.savedIndex;

	yield put({ type: 'CHANGED_STOPS', savedStops });
	yield put({ type: 'SET_CLOSEST_STOP', closestStop });
	yield fork(fetchArrival, action.stopID);
}

function* removeStop(action) {
	const shuttle = yield select(getShuttle);
	const savedStops = shuttle.savedStops.slice();
	const closestStop = Object.assign({}, shuttle.closestStop);

	// Remove stop from saved array
	savedStops.splice(action.stopIndex, 1);

	// Update closestStop index
	--closestStop.savedIndex;

	yield put({ type: 'CHANGED_STOPS', savedStops });
	yield put({ type: 'SET_CLOSEST_STOP', closestStop });
}

function* orderStops(action) {
	try {
		const { newOrder } = action;
		if (newOrder && newOrder.length > 0) {
			const shuttle = yield select(getShuttle);
			const savedStops = shuttle.savedStops.slice();
			const closestStop = Object.assign({}, shuttle.closestStop);
			const { newStops, newClosest } = yield call(doOrder, savedStops, newOrder, closestStop);

			yield put({ type: 'CHANGED_STOPS', savedStops: newStops });
			yield put({ type: 'SET_CLOSEST_STOP', closestStop: newClosest });
		}
	} catch (error) {
		console.log('Error re-ordering stops: ' + error);
	}
}

function doOrder(savedStops, newOrder, closestStop) {
	const newStops = [];
	const oldSavedIndex = Number(closestStop.savedIndex);
	let index;
	for (let i = 0; i < newOrder.length; ++i) {
		if (Number(newOrder[i]) === oldSavedIndex) {
			// Update closest stop index
			closestStop.savedIndex = i;
		} else {
			if (oldSavedIndex < newOrder[i]) {
				index = newOrder[i] - 1;
			} else {
				index = newOrder[i];
			}
			newStops.push(savedStops[index]);
		}
	}
	return { newStops, newClosest: closestStop };
}

function* fetchArrival(stopID) {
	const shuttle = yield select(getShuttle);
	const stops = Object.assign({}, shuttle.stops);

	try {
		const arrivals = yield call(fetchShuttleArrivalsByStop, stopID);

		// Sort arrivals, should be on lambda?
		arrivals.sort((a, b) => {
			const aSecs = a.secondsToArrival;
			const bSecs = b.secondsToArrival;

			if ( aSecs < bSecs ) return -1;
			if ( aSecs > bSecs) return 1;
			return 0;
		});

		stops[stopID].arrivals = arrivals;

		yield put({ type: 'SET_ARRIVALS', stops });
	} catch (error) {
		console.log('Error fetching arrival for ' + stopID + ': ' + error);
	}
}

function* watchArrivals() {
	while (true) {
		const { savedStops, closestStop } = yield select(getShuttle);
		// Fetch arrivals for all saved stops
		for (let i = 0; i < savedStops.length; ++i) {
			const stopID = savedStops[i].id;
			yield call(fetchArrival, stopID);
		}
		if (closestStop) {
			yield call(fetchArrival, closestStop.id); // Fetch arrival for closest stop
		}
		yield delay(60000); // wait 60s before pinging again
	}
}

function* shuttleSaga() {
	yield takeLatest('ADD_STOP', addStop);
	yield takeLatest('REMOVE_STOP', removeStop);
	yield takeLatest('ORDER_STOPS', orderStops);
	yield call(watchArrivals);
}

export default shuttleSaga;
