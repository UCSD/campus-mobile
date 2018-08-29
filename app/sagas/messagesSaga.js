import {
	call,
	put,
	select,
	takeLatest,
	race
} from 'redux-saga/effects'
import { delay } from 'redux-saga'

import MessagesService from '../services/messagesService'
import logger from '../util/logger'
import { MESSAGING_TTL } from '../AppSettings'

const getMessages = state => (state.messages)
const getUserData = state => (state.user)

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
}

export default messagesSaga
