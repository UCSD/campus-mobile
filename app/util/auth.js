import * as Keychain from 'react-native-keychain'
import { put, select } from 'redux-saga/effects'
import { delay } from 'redux-saga'
import {
	SSO_REFRESH_MAX_RETRIES,
	SSO_REFRESH_RETRY_INCREMENT,
	SSO_REFRESH_RETRY_MULTIPLIER
} from '../AppSettings'

const forge = require('node-forge')

const { pki } = forge
const accessTokenSiteName = 'https://ucsd.edu'

// A "private" internal function that lets us
// send a fetchrequest with the correct
// authorization headers
const authorizedFetchRequest = (endpoint, accessToken) => (
	fetch(endpoint, {
		headers: { 'Authorization': `Bearer ${accessToken}` }
	})
		.then((response) => {
			if (response.status === 200) return response.json()
			else {
				switch (response.status) {
					case 401: {
						// We need to refresh our access token
						return { invalidToken: true }
					}
					case 404: {
						return { message: response.statusText }
					}
					default: {
						const e = new Error(response.statusText)
						throw e
					}
				}
			}
		})
)

/**
 * A module containing auth helper functions
 * @module auth
 */
module.exports = {
	/**
	 * Encrypts input using a public key
	 * @param {String} string String to encrypt
	 * @returns {String} Encrypted string
	 */
	encryptStringWithKey(string) {
		const publicKey = pki.publicKeyFromPem(this.ucsdPublicKey)
		const encrypted = publicKey.encrypt(string, 'RSA-OAEP')
		return forge.util.encode64(encrypted)
	},

	/**
	 * Encrypts / encodes input using base64
	 * @param {String} string String to encrypt
	 * @returns {String} Encrypted string
	 */
	encryptStringWithBase64(string) {
		return forge.util.encode64(string)
	},

	/**
	 * Stores user credentials in the keychain
	 * @param {String} user User's username
	 * @param {String} pass User's password
	 * @returns {boolean} True if keychain was stored
	 */
	storeUserCreds(user, pass) {
		return Keychain
			.setGenericPassword(user, pass)
			.then(() => (true))
	},

	/**
	 * Retrieves user credentials in the keychain
	 * @returns {Object} Object containing username and password
	 * or an error if something went wrong
	 */
	retrieveUserCreds() {
		return Keychain
			.getGenericPassword()
			.then(credentials => (credentials))
			.catch(error => (error))
	},

	/**
	 * Deletes user credentials in the keychain
	 * @returns {boolean} True once keychain is reset
	 */
	destroyUserCreds() {
		return Keychain
			.resetGenericPassword()
			.then(() => (true))
	},

	/**
	 * Stores access token in the keychain
	 * @param {String} token Access token to store
	 * @returns {boolean} True if keychain was stored
	 */
	storeAccessToken(token) {
		return Keychain
			.setInternetCredentials(accessTokenSiteName, 'accessToken', token)
			.then(() => (true))
	},

	/**
	 * Retrieves access token in the keychain
	 * @returns {Object} Object containing access token
	 * or an error if something went wrong
	 */
	retrieveAccessToken() {
		return Keychain
			.getInternetCredentials(accessTokenSiteName)
			.then(credentials => (credentials.password))
			.catch(error => (error))
	},

	/**
	 * Deletes access token in the keychain
	 * @returns {boolean} True once keychain is reset
	 */
	destroyAccessToken() {
		return Keychain
			.resetInternetCredentials(accessTokenSiteName)
			.then(() => (true))
	},

	/**
	 * Makes an authorized request using an access token.
	 * If the response is a 401 Unauthorized, this function
	 * attempts to retry a predetermined amount of times.
	 * If no successful response is received by the last
	 * attempt, this function sets an AUTH_HTTP error in
	 * state.requestErrors.
	 * @param {String} endpoint URL of API endpoint
	 * @returns {Object} Data from server
	 * or returns an error if HTTP resonse isn't 200
	 */
	* authorizedFetch(endpoint) {
		yield put({ type: 'AUTH_HTTP_REQUEST' })

		// Check to see if we aren't in an error state
		const userState = state => (state.user)
		const { appUpdateRequired, isLoggedIn } = yield select(userState)
		if (appUpdateRequired) {
			const e = new Error('App update required.')
			yield put({ type: 'AUTH_HTTP_FAILURE', e })
			throw e
		}

		// Check to see if user is logged in
		if (!isLoggedIn) {
			const e = new Error('Not signed in.')
			yield put({ type: 'AUTH_HTTP_FAILURE', e })
			throw e
		}

		let accessToken = yield Keychain
			.getInternetCredentials(accessTokenSiteName)
			.then(credentials => (credentials.password))

		try {
			let endpointResponse = yield authorizedFetchRequest(endpoint, accessToken)

			// Refresh token if invalidToken and retry request
			if (endpointResponse.invalidToken) {
				for (
					let i = 0, remainingRetries = SSO_REFRESH_MAX_RETRIES;
					remainingRetries > 0;
					remainingRetries--, i++
				) {
					// Throw if we're in an error state
					const { invalidSavedCredentials } = yield select(userState)
					if (invalidSavedCredentials) {
						const e = new Error('Unable to re-authorize user')
						throw e
					}

					// Break if we're logged out
					const { isLoggedIn: retryIsLoggedIn } = yield select(userState)
					if (!retryIsLoggedIn) return

					// Attempt to get a new access token
					yield put({ type: 'USER_TOKEN_REFRESH' })

					// Delay next authorized fetch attempt
					let multiplier = SSO_REFRESH_RETRY_MULTIPLIER * i
					if (multiplier === 0) multiplier = 1
					yield delay(SSO_REFRESH_RETRY_INCREMENT * multiplier)

					accessToken = yield Keychain
						.getInternetCredentials(accessTokenSiteName)
						.then(credentials => (credentials.password))

					endpointResponse = yield authorizedFetchRequest(endpoint, accessToken)

					if (!endpointResponse.invalidToken) {
						yield put({ type: 'AUTH_HTTP_SUCCESS' })
						return endpointResponse
					}
				}

				const e = new Error('Unable to re-authorize user')
				throw e
			} else {
				yield put({ type: 'AUTH_HTTP_SUCCESS' })
				return endpointResponse
			}
		} catch (error) {
			if (error.message === 'Unable to re-authorize user') {
				// We were unable to get an authorized response.
				// We need to ask the user to reauthenticate some
				// other time.

				yield put({ type: 'AUTH_HTTP_FAILURE', error })
			}
			throw error
		}
	},

	ucsdPublicKey: '-----BEGIN PUBLIC KEY-----\n' +
		'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n' +
		'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n' +
		'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n' +
		'CaCUGqS6FN1nNKARGwIDAQAB\n' +
		'-----END PUBLIC KEY-----'
}
