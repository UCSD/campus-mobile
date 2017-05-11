import { delay } from 'redux-saga';
import { call, put, takeLatest } from 'redux-saga/effects';

function* doLogin(action) {
	yield put({ type: 'LOGGED_IN', user: action.user });
}

function* doLogout(action) {
	yield put({ type: 'LOGGED_OUT' });
}

function* userSaga() {
	yield takeLatest('USER_LOGIN', doLogin);
	yield takeLatest('USER_LOGOUT', doLogout);
}

export default userSaga;
