import {
	call,
	put,
	select,
	takeLatest,
	race
} from 'redux-saga/effects'
import { delay } from 'redux-saga'
import moment from 'moment'
import ssoService from '../services/ssoService'
import { SSO_TTL } from '../AppSettings'
import logger from '../util/logger'

const auth = require('../util/auth')

const getUserData = state => (state.user)

function* doLogin(action) {
	const { username, password } = action

	try {
		if (!password || password.length === 0) {
			const e = new Error('Please type in your password.')
			e.name = 'emptyPasswordError'
			throw e
		}
		const passwordEncrypted = yield auth.encryptStringWithKey(password)
		const loginInfo = auth.encryptStringWithBase64(`${username}:${passwordEncrypted}`)

		yield put({ type: 'IS_LOGGING_IN' })
		const { response, timeout } = yield race({
			response: call(ssoService.retrieveAccessToken, loginInfo),
			timeout: call(delay, SSO_TTL)
		})

		if (timeout) {
			const e = new Error('Logging in timed out.')
			e.name = 'ssoTimeout'
			throw e
		} else if (response.error) {
			logger.log(response)
			throw response.error
		} else {
			// Successfully logged in
			yield auth.storeUserCreds(username, password)
			yield auth.storeAccessToken(response.access_token)


			// Set up user profile
			const newProfile = {
				username,
				pid: response.pid,
				classifications: { student: Boolean(response.pid) }
			}

			yield put({ type: 'LOGGED_IN', profile: newProfile, expiration: response.expiration })
			yield put({ type: 'TOGGLE_AUTHENTICATED_CARDS' })
		}
	} catch (error) {
		logger.log(error)
		yield put({ type: 'USER_LOGIN_FAILED', error: error.message })
	}
}

function* doTokenRefresh() {
	const { expiration } = yield select(getUserData)

	// Check if expiration time is past current time
	if (moment().isAfter(moment.unix(expiration))) {
		// Get username and password from keystore
		const { username, password } = yield auth.retrieveUserCreds()

		yield put({ type: 'USER_LOGIN', username, password })
	}
}

function* doLogout(action) {
	yield auth.destroyUserCreds()
	yield auth.destroyAccessToken()
	yield put({ type: 'LOGGED_OUT' })
	yield put({ type: 'TOGGLE_AUTHENTICATED_CARDS' })
}

function* timeoutError() {
	const error = new Error('There was a problem signing in. Please try again later.')
	yield put({ type: 'USER_LOGIN_FAILED', error: error.message })
}

function* clearErrors(action) {
	yield put({ type: 'USER_SET_ERRORS', error: null })
}

function* userSaga() {
	yield takeLatest('USER_LOGIN', doLogin)
	yield takeLatest('USER_LOGOUT', doLogout)
	yield takeLatest('USER_TOKEN_REFRESH', doTokenRefresh)
	yield takeLatest('USER_LOGIN_TIMEOUT', timeoutError)
	yield takeLatest('USER_CLEAR_ERRORS', clearErrors)
}

export default userSaga
