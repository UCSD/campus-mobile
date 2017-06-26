import { delay } from 'redux-saga';
import { call, put, takeLatest } from 'redux-saga/effects';
import * as Keychain from 'react-native-keychain';

function* doLogin(action) {
	const serviceName = 'ucsdapp';
	const username = action.username;
	const password = action.password;

	yield Keychain.setGenericPassword(username, password, serviceName);
	yield put({ type: 'LOGGED_IN', user: username });
}

function* doLogout(action) {
	yield put({ type: 'LOGGED_OUT' });
}

function* userSaga() {
	yield takeLatest('USER_LOGIN', doLogin);
	yield takeLatest('USER_LOGOUT', doLogout);
}

export default userSaga;
