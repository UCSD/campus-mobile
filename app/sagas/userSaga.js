import { call, put, takeLatest, race } from 'redux-saga/effects';
import { delay } from 'redux-saga';
import ssoService from '../services/ssoService';
import { SSO_TTL } from '../AppSettings';
import logger from '../util/logger';

const auth = require('../util/auth');

function* doLogin(action) {
	const username = action.username;
	const password = action.password;

	/* const passwordEncrypted = yield auth.encryptStringWithKey(password);
	const loginInfo = auth.encryptStringWithBase64(
		`${username}:${passwordEncrypted}`
	); */

	const loginInfo = auth.encryptStringWithBase64(
		`${action.username}:${action.password}`
	);

	try {
		yield put({ type: 'IS_LOGGING_IN' });
		const { response, timeout } = yield race({
			response: call(ssoService.retrieveAccessToken, loginInfo),
			timeout: call(delay, SSO_TTL)
		});

		if (timeout) {
			const e = new Error('Logging in timed out.');
			e.name = 'ssoTimeout';
			throw e;
		} else if (response.error) {
			logger.log(response);
			throw response.error;
		} else {
			// Successfully logged in
			yield auth.storeUserCreds(username, password);
			yield auth.storeAccessToken(response.access_token);
			yield put({ type: 'LOGGED_IN', user: username, expiration: response.expiration });
		}
	} catch (error) {
		logger.log(error);
		yield put({ type: 'USER_LOGIN_FAILED', error });
	}
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
