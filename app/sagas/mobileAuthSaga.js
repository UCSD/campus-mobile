import {
	call,
	put,
	race,
	takeLatest
} from 'redux-saga/effects'
import { delay } from 'redux-saga'


import mobileAuthService from '../services/mobileAuthService'
import auth from '../util/auth'
import logger from '../util/logger'
import { PUBLIC_MOBILE_AUTH_TIMEOUT } from '../AppSettings'


function* updateMobileAuthToken() {
	try {
		// these three lines need to be moved to the upgrade script in AppRedux.js
		const storedCreds = yield auth.storeMobileCreds('MOBILE_PUBLIC_API_KEY_PH', 'MOBILE_PUBLIC_API_SECRET_PH')
		// these three lines need to be moved to the upgrade script in AppRedux.js
		yield put({ type: 'GET_MOBILE_AUTH_TOKEN_REQUEST' })
		// username is the key password is the secret
		const { username, password } = yield auth.retrieveMobileCreds()
		// encryption step
		const authInfo = auth.encryptStringWithBase64(username + ':' + password)
		// fetch token using encrypted credentials
		const { response, timeout } = yield race({
			response: call(mobileAuthService.retrieveAccessToken, authInfo),
			timeout: call(delay, PUBLIC_MOBILE_AUTH_TIMEOUT)
		})
		// check if the request timed out or if there were other errors
		if (timeout) {
			const e = new Error('Updating mobile auth token timed out.')
			e.name = 'mobileAuthTimeout'
			throw e
		} else if (response.error) {
			const appUpdateError = new Error('App update required.')
			throw appUpdateError
		} else {
			// safely store the token
			const storedToken = yield auth.storePublicAccessToken(response.access_token)
			if (storedToken) {
				yield put({ type: 'GET_MOBILE_AUTH_TOKEN_SUCCESS' })
			} else {
				const error = new Error('Could not store token.')
				yield put({ type: 'GET_MOBILE_AUTH_TOKEN_FAILURE', error  })
			}
		}
	} catch (error) {
		yield put({ type: 'GET_MOBILE_AUTH_TOKEN_FAILURE', error })
		logger.trackException(error)
	}
}

function* mobileAuthSaga() {
	yield takeLatest('UPDATE_MOBILE_AUTH_TOKEN', updateMobileAuthToken)
}

export default mobileAuthSaga
