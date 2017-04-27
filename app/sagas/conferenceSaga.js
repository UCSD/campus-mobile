import { put, select, takeLatest } from 'redux-saga/effects';

const getConference = (state) => (state.conference);

function* addConference(action) {
	const conference = yield select(getConference);
	const saved = [...conference.saved.slice()]; // copy array
	let contains = false;
	// Make sure stop hasn't already been saved
	for (let i = 0;  i < saved.length; ++i) {
		if (saved[i] === action.id) {
			contains = true;
			break;
		}
	}
	if (!contains) {
		yield put({ type: 'CHANGED_CONFERENCE_SAVED',
			saved: [...saved, action.id] });
	} // TODO: sort by time
}

function* removeConference(action) {
	const conference = yield select(getConference);
	const saved = conference.saved.slice(); // copy array

	let i;
	// Remove stop from saved array
	for (i = 0; i < saved.length; ++i) {
		if (saved[i] === action.id) {
			saved.splice(i, 1);
			break;
		}
	}

	yield put({ type: 'CHANGED_CONFERENCE_SAVED', saved });
}

function* conferenceSaga() {
	yield takeLatest('ADD_CONFERENCE', addConference);
	yield takeLatest('REMOVE_CONFERENCE', removeConference);
}

export default conferenceSaga;
