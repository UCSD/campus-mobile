import { put, select, takeLatest } from 'redux-saga/effects';

const getSpecialEvents = (state) => (state.specialEvents);

function* addSpecialEvents(action) {
	const specialEvents = yield select(getSpecialEvents);

	if (Array.isArray(specialEvents.saved)) {
		const saved = specialEvents.saved.slice(); // copy array
		const schedule = specialEvents.data.schedule;
		let contains = false;
		let addIndex = 0;
		// Make sure stop hasn't already been saved
		for (let i = 0;  i < saved.length; ++i) {
			if (saved[i] === action.id) {
				contains = true;
				break;
			}
			// figure out where to insert with respect to start time
			if (schedule[action.id]['start-time'] > schedule[saved[i]]['start-time']) {
				addIndex = i + 1;
			}
		}
		if (!contains) {
			yield put({ type: 'CHANGED_SPECIAL_EVENTS_SAVED',
				saved: [...saved.slice(0, addIndex), action.id, ...saved.slice(addIndex)] });
		}
	}
}

function* removeSpecialEvents(action) {
	const specialEvents = yield select(getSpecialEvents);

	if (Array.isArray(specialEvents.saved)) {
		const saved = specialEvents.saved.slice(); // copy array
		// Remove stop from saved array
		for (let i = 0; i < saved.length; ++i) {
			if (saved[i] === action.id) {
				saved.splice(i, 1);
				break;
			}
		}
		yield put({ type: 'CHANGED_SPECIAL_EVENTS_SAVED', saved });
	}
}

function* updateLabels(action) {
	const { labels } = action;
	yield put({ type: 'CHANGED_SPECIAL_EVENTS_LABELS', labels });
}

function* specialEventsSaga() {
	yield takeLatest('ADD_SPECIAL_EVENTS', addSpecialEvents);
	yield takeLatest('REMOVE_SPECIAL_EVENTS', removeSpecialEvents);
	yield takeLatest('UPDATE_SPECIAL_EVENTS_LABELS', updateLabels);
}

export default specialEventsSaga;
