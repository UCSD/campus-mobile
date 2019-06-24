import {
	call,
	put,
	select,
	takeLatest
} from 'redux-saga/effects'


import mobileAuthService from '../services/mobileAuthService'
import auth from '../util/auth'
import logger from '../util/logger'


function* updateMobileAuthToken() {
	try {
		// these three lines need to be moved to the upgrade script in AppRedux.js
		const storedCreds = yield auth.storeMobileCreds('MOBILE_PUBLUIC_API_KEY_PH', 'MOBILE_PUBLUIC_API_SECRET_PH')
		// these three lines need to be moved to the upgrade script in AppRedux.js
		yield put({ type: 'GET_MOBILE_AUTH_TOKEN_REQUEST' })
		// username is the key password is the secret
		const { username, password } = yield auth.retrieveMobileCreds()
		// encryption step
		const authInfo = auth.encryptStringWithBase64(username + ':' + password)
		// fetch token using encrypted credentials
		const response = yield call(mobileAuthService.retrieveAccessToken, authInfo)
		console.log(response)
		// safely store the token
		const storedToken = yield auth.storePublicAccessToken(response.access_token)
		if (storedToken) {
			yield put({ type: 'GET_MOBILE_AUTH_TOKEN_SUCCESS' })
		} else {
			const error = 'could not store token'
			yield put({ type: 'GET_MOBILE_AUTH_TOKEN_FAILURE', error  })
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
