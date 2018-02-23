import { call, put, takeLatest } from 'redux-saga/effects';
import { delay } from 'redux-saga';

const auth = require('../util/auth');

function* doLogin(action) {
	const passwordEncrypted = yield auth.encryptStringWithKey(action.password);
	console.log(passwordEncrypted);
	const loginInfo = auth.encryptStringWithBase64(
		`${action.username}:${passwordEncrypted}`
	);

	console.log(loginInfo);

	// TODO: Send to auth service to verify before actually doing login
	/* Logic for using ssoService
	try {
		yield put({ type: 'IS_LOGGING_IN' });
		const { response, timeout } yield race({
			response: call(ssoService.retrieveAccessToken, loginInfo),
			timeout: call(delay, SSO_TTL)
		});

		if (timeout) {
			const e = new Error('Logging in timed out.')
			e.name = 'ssoTimeout';
			throw e;
		} else if (response.error) {
			logger.log(response);
			throw response.error;
		} else {
			// Successfully logged in
			yield auth.storeUserCreds(username, password);
			yield auth.storeAccessToken(response.accessToken);
			yield put({ type: 'LOGGED_IN', user: username });
		}
	} catch (error) {
		logger.log(error);
		yield put({ type: 'USER_LOGIN_FAILED', error})
	}

	*/

	// Temporary test logic
	yield put({ type: 'IS_LOGGING_IN' });
	yield call(delay, 2000);
	// const error = new Error('Invalid credentials entered.');
	// error.name = 'ssoInvalidCreds';
	// yield put({ type: 'USER_LOGIN_FAILED', error });
	yield auth.storeAccessToken('testToken');
	yield put({ type: 'LOGGED_IN', user: action.username });
}

function* doLogout(action) {
	yield auth.destroyUserCreds();
	yield auth.destroyAccessToken();
	yield put({ type: 'LOGGED_OUT' });
}

function* userSaga() {
	yield takeLatest('USER_LOGIN', doLogin);
	yield takeLatest('USER_LOGOUT', doLogout);
}

export default userSaga;
