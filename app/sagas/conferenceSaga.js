import { put, select, takeLatest } from 'redux-saga/effects';

const getConference = (state) => (state.conference);

function* addConference(action) {
	const conference = yield select(getConference);

	if (Array.isArray(conference.saved)) {
		const saved = conference.saved.slice(); // copy array
		const schedule = conference.data.schedule;
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
			yield put({ type: 'CHANGED_CONFERENCE_SAVED',
				saved: [...saved.slice(0, addIndex), action.id, ...saved.slice(addIndex)] });
		}
	}
}

function* removeConference(action) {
	const conference = yield select(getConference);

	if (Array.isArray(conference.saved)) {
		const saved = conference.saved.slice(); // copy array
		// Remove stop from saved array
		for (let i = 0; i < saved.length; ++i) {
			if (saved[i] === action.id) {
				saved.splice(i, 1);
				break;
			}
		}
		yield put({ type: 'CHANGED_CONFERENCE_SAVED', saved });
	}
}

function* conferenceSaga() {
	yield takeLatest('ADD_CONFERENCE', addConference);
	yield takeLatest('REMOVE_CONFERENCE', removeConference);
}

export default conferenceSaga;
