import {
	all,
	call,
	put,
	select,
	takeLatest,
	race
} from 'redux-saga/effects'
import { delay } from 'redux-saga'
import Device from 'react-native-device-info'
import firebase from 'react-native-firebase'
import moment from 'moment'
import Toast from 'react-native-simple-toast'

import MessagesService from '../services/messagesService'
import logger from '../util/logger'
import { MESSAGING_TTL } from '../AppSettings'

const getUserData = state => (state.user)
const getMessages = state => (state.messages)

function* getTopics() {
	try {
		yield put({ type: 'GET_TOPICS_REQUEST' })

		const { response, timeout } = yield race({
			response: call(MessagesService.FetchTopics),
			timeout: call(delay, MESSAGING_TTL)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			throw e
		}
		else if (response) {
			yield put({ type: 'SET_TOPICS', topics: response })
			yield put({ type: 'GET_TOPICS_SUCCESS' })
		}
	} catch (error) {
		yield put({ type: 'GET_TOPICS_FAILED', error })
		logger.trackException(error, false)
	}
}

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

// Intended to be used when the user is logging out
function* resetMessages() {
	yield put({ type: 'CLEAR_MESSAGE_DATA' })
	yield put({ type: 'UPDATE_MESSAGES' })
}

function* updateMessages(action) {
	const { timestamp } = action
	const { isLoggedIn, profile } = yield select(getUserData)
	const { messages } = yield select(getMessages)

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
				const { messages: newMessages, next: nextTimestamp } = response
				const newMessagesArray = mergeMessagesArrays(messages, newMessages)
				const sortedMessages = newMessagesArray.sort(( left, right ) =>
					moment.utc(right.timestamp).diff(moment.utc(left.timestamp)))

				let count = 0
				// check for how many of the new messages have a timestamp after latestTimeStamp
				// latestTimeStamp is set when the user last opened the notfications pages
				let { length } = sortedMessages
				if (sortedMessages.length > 10) {
					length = 10
				}
				for (let i = 0; i < length; i++) {
					if (sortedMessages[i].timestamp > profile.latestTimeStamp) {
						count++
					}
				}
				yield put({ type: 'SET_UNREAD_MESSAGES', count })
				yield put({ type: 'SET_MESSAGES', messages: sortedMessages, nextTimestamp })
				yield put({ type: 'GET_MESSAGES_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_MESSAGES_FAILURE', error })
			logger.trackException(error, false)
			Toast.showWithGravity(
				'Opps. There was a network problem.',
				Toast.SHORT,
				Toast.BOTTOM
			)
		}
	}
}


function* subscribeToTopic(action) {
	const { topicId } = action
	const { profile } = yield select(getUserData)

	let newTopicSubscriptions = []
	if (Array.isArray(profile.subscribedTopics)) {
		newTopicSubscriptions = [...profile.subscribedTopics]
	}
	newTopicSubscriptions.push(topicId)
	const profileItems = { subscribedTopics: newTopicSubscriptions }

	yield firebase.messaging().subscribeToTopic(topicId)
	console.log('Subscribed to', topicId)
	yield put({ type: 'MODIFY_LOCAL_PROFILE', profileItems })
}

function* unsubscribeFromTopic(action) {
	const { topicId } = action
	const { profile } = yield select(getUserData)

	let newTopicSubscriptions = []
	if (Array.isArray(profile.subscribedTopics)) {
		newTopicSubscriptions = [...profile.subscribedTopics]
	}
	const topicIndex = newTopicSubscriptions.indexOf(topicId)
	newTopicSubscriptions.splice(topicIndex, 1)
	const profileItems = { subscribedTopics: newTopicSubscriptions }

	yield firebase.messaging().unsubscribeFromTopic(topicId)
	console.log('Unsubscribed from', topicId)
	yield put({ type: 'MODIFY_LOCAL_PROFILE', profileItems })
}

// Removes all topic subscriptions except for the default 'all' topic
function* clearUserSubscriptions(action) {
	const defaultSubscriptions = ['emergency', 'all']

	const { subscribedTopics } = action
	if (Array.isArray(subscribedTopics)) {
		yield all(subscribedTopics.map(topic => (
			call(() => {
				if (defaultSubscriptions.indexOf(topic) < 0) {
					firebase.messaging().unsubscribeFromTopic(topic)
					console.log('Unsubscribed from', topic)
				}
			})
		)))

		const profileItems = { subscribedTopics: defaultSubscriptions }
		yield put({ type: 'MODIFY_LOCAL_PROFILE', profileItems })
	}
}

// Subscribes to all topics in profile.subscribedTopics
// used when settings have been synced from the server
function* refreshTopicSubscriptions(action) {
	const { profile } = yield select(getUserData)

	if (Array.isArray(profile.subscribedTopics)) {
		yield all(profile.subscribedTopics.map(topic => (
			call(() => {
				firebase.messaging().subscribeToTopic(topic)
				console.log('Subscribed to', topic)
			})
		)))
	}
}

function mergeMessagesArrays(old, updated) {
	const messages = {}

	if (Array.isArray(old)) {
		old.forEach((message) => {
			messages[message.messageId] = message
		})
	}

	if (Array.isArray(updated)) {
		updated.forEach((message) => {
			messages[message.messageId] = message
		})
	}

	const result = []
	Object.keys(messages).forEach((messageId) => {
		result.push(messages[messageId])
	})

	return result
}

function* messagesSaga() {
	yield takeLatest('RESET_MESSAGES', resetMessages)
	yield takeLatest('UPDATE_MESSAGES', updateMessages)
	yield takeLatest('REGISTER_TOKEN', registerToken)
	yield takeLatest('UNREGISTER_TOKEN', unregisterToken)
	yield takeLatest('GET_TOPICS', getTopics)
	yield takeLatest('SUBSCRIBE_TO_TOPIC', subscribeToTopic)
	yield takeLatest('UNSUBSCRIBE_FROM_TOPIC', unsubscribeFromTopic)
	yield takeLatest('CLEAR_USER_SUBSCRIPTIONS', clearUserSubscriptions)
	yield takeLatest('REFRESH_TOPIC_SUBSCRIPTIONS', refreshTopicSubscriptions)
}

export default messagesSaga
