import {
	call,
	put,
	select,
	takeLatest,
	race
} from 'redux-saga/effects'
import { delay } from 'redux-saga'
import Device from 'react-native-device-info'
import firebase from 'react-native-firebase'

import MessagesService from '../services/messagesService'
import logger from '../util/logger'
import { MESSAGING_TTL } from '../AppSettings'

const getMessages = state => (state.messages)
const getUserData = state => (state.user)

function* registerToken(action) {
	const { token } = action
	const { isLoggedIn } = yield select(getUserData)

	if (isLoggedIn) {
		try {
			yield put({ type: 'POST_TOKEN_REQUEST' })

			const { response, timeout } = yield race({
				response: call(MessagesService.PostPushToken, token, Device.getUniqueID()),
				timeout: call(delay, MESSAGING_TTL)
			})

			if (timeout) {
				const e = new Error('Request timed out.')
				throw e
			}
			else if (response) {
				yield put({ type: 'CONFIRM_REGISTRATION' })
				yield put({ type: 'POST_TOKEN_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'POST_TOKEN_FAILED', error })
			logger.trackException(error, false)
		}
	}
}

function* unregisterToken(action) {
	const { accessToken } = action
	const fcmToken = yield firebase.messaging().getToken()

	try {
		yield put({ type: 'POST_TOKEN_REQUEST' })

		const { response, timeout } = yield race({
			response: call(MessagesService.DeletePushToken, fcmToken, accessToken),
			timeout: call(delay, MESSAGING_TTL)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			throw e
		}
		else if (response) {
			yield put({ type: 'CONFIRM_DEREGISTRATION' })
			yield put({ type: 'POST_TOKEN_SUCCESS' })
		}
	} catch (error) {
		yield put({ type: 'POST_TOKEN_FAILED', error })
		logger.trackException(error, false)
	}
}

function* updateMessages(action) {
	const { timestamp } = action
	const { isLoggedIn } = yield select(getUserData)

	if (isLoggedIn) {
		try {
			yield put({ type: 'GET_MESSAGES_REQUEST' })

			const { response, timeout } = yield race({
				response: call(MessagesService.FetchMyMessages, timestamp),
				timeout: call(delay, MESSAGING_TTL)
			})

			if (timeout) {
				const e = new Error('Request timed out.')
				throw e
			}
			else {
				const { messages, next: nextTimestamp } = response

				yield put({ type: 'SET_MESSAGES', messages, nextTimestamp })
				yield put({ type: 'GET_MESSAGES_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_MESSAGES_FAILURE', error })
			logger.trackException(error, false)
		}
	}
}

function* messagesSaga() {
	yield takeLatest('UPDATE_MESSAGES', updateMessages)
	yield takeLatest('REGISTER_TOKEN', registerToken)
	yield takeLatest('UNREGISTER_TOKEN', unregisterToken)
}

export default messagesSaga
