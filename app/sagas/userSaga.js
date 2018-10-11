import {
	call,
	put,
	takeLatest,
	race,
	select
} from 'redux-saga/effects'
import { delay } from 'redux-saga'
import { Alert } from 'react-native'
import firebase from 'react-native-firebase'

import ssoService from '../services/ssoService'
import userService from '../services/userService'
import {
	SSO_TTL,
	SSO_IDP_ERROR_RETRY_INCREMENT,
	USER_PROFILE_SYNC_TTL,
} from '../AppSettings'
import logger from '../util/logger'

const auth = require('../util/auth')

const userState = state => (state.user)

// This function is used when a user manually submits
// credentials to sign in with.
function* doLogin(action) {
	const { username, password } = action

	if ((username === 'studentdemo' && password === 'studentdemo') ||
		(username === 'demo' && password === 'demo')) {
		// DEMO ACCOUNT LOGIN
		yield activateDemoAccount(username, password)
	} else {
		// NORMAL LOGIN
		yield put({ type: 'LOG_IN_REQUEST' })
		try {
			if (!password || password.length === 0) {
				const e = new Error('Please type in your password.')
				e.name = 'emptyPasswordError'
				yield call(delay, 0)
				throw e
			}
			const passwordEncrypted = yield auth.encryptStringWithKey(password)
			const loginInfo = auth.encryptStringWithBase64(`${username}:${passwordEncrypted}`)

			const { response, timeout } = yield race({
				response: call(ssoService.retrieveAccessToken, loginInfo),
				timeout: call(delay, SSO_TTL)
			})

			if (timeout) {
				const e = new Error('Logging in timed out.')
				e.name = 'ssoTimeout'
				throw e
			} else if (response.error) {
				if (response.error.appUpdateRequired) {
					yield outOfDateAlert()
					const appUpdateError = new Error('App update required.')
					throw appUpdateError
				} else {
					logger.log(response)
					throw response.error
				}
			} else {
				// Successfully logged in
				yield auth.storeUserCreds(username, passwordEncrypted)
				yield auth.storeAccessToken(response.access_token)

				// Set up user profile
				const newProfile = {
					username,
					pid: response.pid,
					classifications: { student: Boolean(response.pid) }
				}

				// Post sign-in flow
				// Toggles any cards that should show up for the signed in user
				// Registers firebase push token
				// Queries any user data with newly obtained access token
				yield put({ type: 'LOGGED_IN', profile: newProfile })
				yield put({ type: 'LOG_IN_SUCCESS' })
				yield put({ type: 'TOGGLE_AUTHENTICATED_CARDS' })

				const fcmToken = yield firebase.messaging().getToken()
				if (fcmToken) yield put({ type: 'REGISTER_TOKEN', token: fcmToken })

				// Clears any potential errors from being
				// unable to automatically reauthorize a user
				yield put({ type: 'AUTH_HTTP_SUCCESS' })

				yield call(queryUserData)
			}
		} catch (error) {
			logger.trackException(error)
			yield put({ type: 'LOG_IN_FAILURE', error })
		}
	}
}

function* queryUserData() {
	// USER PROFILE SYNC
	// Sync user profile from cloud when first logging in
	yield call(getUserProfile)
	const { profile, syncedProfile } = yield select(userState)

	// If newly signed in user fits into certain categories,
	// subscribe them to their topics.
	if (profile.classifications) {
		if (profile.classifications.student) {
			// subscribe to default student topics
			yield put({ type: 'SUBSCRIBE_TO_TOPIC', topicId: 'students' })
		}
	}

	// If their synced profile has unsubscribed from these topics,
	// that is synced in the next few steps and handled accordingly

	// populate newProfile with potentially stale remote data first
	let profileItems = { ...syncedProfile }

	// add newly initialized profile object
	profileItems = { ...profileItems }

	// only sync data that is dependent on the user signing in
	if (profile.username) profileItems.username = profile.username
	if (profile.classifications) profileItems.classifications = { ...profile.classifications }
	if (profile.pid) profileItems.pid = profile.pid

	const modifyProfileAction = { profileItems }

	yield call(modifyLocalProfile, modifyProfileAction)

	// subscribes to firebase topics that have been synced from the server
	yield put({ type: 'REFRESH_TOPIC_SUBSCRIPTIONS' })

	// INITIAL USER DATA CALLS
	// perform first data calls when user is logged in
	yield put({ type: 'UPDATE_SCHEDULE' })
	yield put({ type: 'UPDATE_MESSAGES' })
}
// Used when an API call requires an access token and the current
// one is stale.
function* doTokenRefresh() {
	try {
		yield refreshTokenRequest()
	} catch (error) {
		const invalidCredsMessage = 'Be sure you are using the correct credentials; TritonLink login if you are a student, SSO if you are Faculty/Staff.'
		if (error.message === invalidCredsMessage) {
			// This means that the authentication server rejected our
			// saved credentials. Did the user's password change? Only retry
			// once, and if it fails again, force a sign-out.
			try {
				// Try once more with a delay just to be sure
				yield delay(SSO_IDP_ERROR_RETRY_INCREMENT)
				yield refreshTokenRequest()
			} catch (secondError) {
				if (secondError.message === invalidCredsMessage) {
					// We tried again and got the same error
					yield put({ type: 'PANIC_LOG_OUT' })
					const invalidCredsError = new Error('InvalidCreds Error')
					logger.trackException(invalidCredsError)
					yield call(clearUserData)
				}
			}
		}
	}
}

// Utility method that actually makes the request for the new
// access token using encrypted stored credentials
function* refreshTokenRequest() {
	const { isLoggedIn } = yield select(userState)
	if (!isLoggedIn) {
		const e = new Error('Not signed in.')
		throw e
	}

	// Get username and password from keystore
	const {
		username,
		password
	} = yield auth.retrieveUserCreds()
	const loginInfo = auth.encryptStringWithBase64(`${username}:${password}`)
	const response = yield call(ssoService.retrieveAccessToken, loginInfo)

	if (response.error && response.error.appUpdateRequired) {
		yield outOfDateAlert()
	}
	else if (response.access_token) {
		yield auth.storeAccessToken(response.access_token)
		// Clears any potential errors from being
		// unable to automatically reauthorize a user
		yield put({ type: 'AUTH_HTTP_SUCCESS' })
	} else {
		const e = new Error('No access token returned.')
		throw e
	}
}

// Obtains the user profile stored in the cloud
function* getUserProfile() {
	// Request user profile from API
	yield put({ type: 'GET_PROFILE_REQUEST' })

	try {
		const profile = yield call(userService.FetchUserProfile)
		yield put({ type: 'GET_PROFILE_SUCCESS' })

		if (profile) {
			yield put({ type: 'SET_USER_PROFILE', profileItems: profile })
		}
	} catch (error) {
		yield put({ type: 'GET_PROFILE_FAILURE' })
		logger.trackException(error)
	}
}

// Times out any current logging-in process
function* doTimeOut() {
	const error = new Error('Logging in timed out.')
	yield put({ type: 'LOG_IN_FAILURE', error })
}

// Logs out the user
function* doLogout(action) {
	const { profile } = yield select(userState)
	const { subscribedTopics: currentSubscriptions } = profile

	// We need to pass in the accessToken before we lose it
	// This isn't guaranteed to work but we should try anyways
	const accessToken = yield auth.retrieveAccessToken()
	yield put({ type: 'UNREGISTER_TOKEN', accessToken })

	yield put({ type: 'LOGGED_OUT' })
	yield call(clearUserData, currentSubscriptions)
}

function* outOfDateAlert() {
	yield put({ type: 'APP_UPDATE_REQUIRED' })

	Alert.alert(
		'App Update Required',
		'If you would like to log in, please update the app.',
		[
			{
				text: 'OK',
				style: 'cancel'
			}
		],
		{ cancelable: false }
	)
}

// Syncs local profile with remote user profile stored in the cloud
function* syncUserProfile() {
	const { isLoggedIn, profile, lastSynced } = yield select(userState)

	if (!isLoggedIn) return

	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastSynced
	const syncTTL = USER_PROFILE_SYNC_TTL

	if (timeDiff < syncTTL) return

	// Get latest profile from server
	yield getUserProfile()

	// Update remote profile with local one
	const newAttributes = []

	Object.keys(profile).forEach((key) => {
		newAttributes.push({
			attribute: key,
			value: profile[key],
		})
	})

	yield put({ type: 'POST_PROFILE_REQUEST' })
	try {
		yield call(userService.PostUserProfile, newAttributes)
		yield put({ type: 'POST_PROFILE_SUCCESS' })
		yield put({ type: 'PROFILE_SYNCED' })

		// subscribes to firebase topics that have been synced from the server
		yield put({ type: 'REFRESH_TOPIC_SUBSCRIPTIONS' })
	} catch (error) {
		yield put({ type: 'POST_PROFILE_FAILURE' })
		logger.trackException(error)
	}
}

// Handles modifying the local user profile object.
// If the user is signed in, initiates a sync attempt
// with the remote server
function* modifyLocalProfile(action) {
	const { profileItems } = action
	console.log(profileItems.selectedLots)
	yield put({ type: 'SET_LOCAL_PROFILE', profileItems })
	yield put({ type: 'RESET_SYNCED_DATE' })
	yield call(syncUserProfile)

	// if profile change includes changes to subscriptions, reset messages
	if (profileItems.subscribedTopics) yield put({ type: 'RESET_MESSAGES' })
}

// Handles signing in to the fake student demo account
// username and password are both "demo"
function* activateDemoAccount(demoUsername, demoPassword) {
	yield put({ type: 'LOG_IN_REQUEST' })
	yield put({ type: 'ACTIVATE_STUDENT_DEMO_ACCOUNT' })
	yield call(delay, 750)

	// Successfully logged in
	yield auth.storeUserCreds(demoUsername, demoPassword)

	// Set up user profile
	const newProfile = {
		username: 'Student Demo',
		pid: 'fakepid',
		classifications: { student: true }
	}

	yield put({ type: 'LOGGED_IN', profile: newProfile })
	yield put({ type: 'LOG_IN_SUCCESS' })
	yield put({ type: 'TOGGLE_AUTHENTICATED_CARDS' })

	// Clears any potential errors from being
	// unable to automatically reauthorize a user
	yield put({ type: 'AUTH_HTTP_SUCCESS' })

	yield call(queryUserData)
}


// Performs various cleanup actions. These include:
// Unregistering / unassociating the firebase push token
// Clearing any user specific data (but not any default preferences
// such as card order or subscriptions to default notification categories)
function* clearUserData(currentSubscriptions) {
	yield put({ type: 'TOGGLE_AUTHENTICATED_CARDS' })
	yield auth.destroyUserCreds()
	yield auth.destroyAccessToken()
	yield put({ type: 'CLEAR_SCHEDULE_DATA' })
	yield put({ type: 'CLEAR_USER_SUBSCRIPTIONS', subscribedTopics: currentSubscriptions })
	yield put({ type: 'RESET_MESSAGES' })
}

function* userSaga() {
	yield takeLatest('USER_LOGIN', doLogin)
	yield takeLatest('USER_LOGOUT', doLogout)
	yield takeLatest('USER_LOGIN_TIMEOUT', doTimeOut)
	yield takeLatest('USER_TOKEN_REFRESH', doTokenRefresh)
	yield takeLatest('GET_USER_PROFILE', getUserProfile)
	yield takeLatest('MODIFY_LOCAL_PROFILE', modifyLocalProfile)
	yield takeLatest('SYNC_USER_PROFILE', syncUserProfile)
}

export default userSaga
