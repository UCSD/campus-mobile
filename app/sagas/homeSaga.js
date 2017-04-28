import { put, takeLatest } from 'redux-saga/effects';

function* resetScroll() {
	yield put({ type: 'SET_HOME_SCROLL', lastScroll: 0 });
}

function* setScroll(action) {
	yield put({ type: 'SET_HOME_SCROLL', lastScroll: action.scrollY });
}

function* homeSaga() {
	yield takeLatest('UPDATE_HOME_SCROLL', setScroll);
}

export default homeSaga;
