import { authorizedFetch } from '../util/auth'

const {
	MYMESSAGES_API_URL,
	MESSAGES_TOPICS_URL,
	PUSH_REGISTRATION_API_URL,
} = require('../AppSettings')

const MyMessagesService = {
	* FetchTopics() {
		try {
			const topics = yield (yield fetch(MESSAGES_TOPICS_URL)).json()

			if (Object.keys(topics).length > 0) return topics
			else {
				const e = new Error('Invalid data from messages API')
				throw e
			}
		} catch (error) {
			throw error
		}
	},

	* FetchMyMessages(timestamp) {
		try {
			let query = '?start=' + new Date().getTime()
			if (timestamp) query = '?start=' + timestamp

			const messages = JSON.parse(yield authorizedFetch(`${MYMESSAGES_API_URL}/messages${query}`))

			if (messages && messages.messages) return messages
			else {
				const e = new Error('Invalid data from messages API')
				throw e
			}
		} catch (error) {
			throw error
		}
	},

	* FetchTopicMessages(topic, timestamp) {
		try {
			const messages = JSON.parse(yield authorizedFetch(`${MYMESSAGES_API_URL}/topic/${topic}`))

			if (messages) return { messages }
			else {
				const e = new Error('Invalid data from messages API')
				throw e
			}
		} catch (error) {
			throw error
		}
	},

	* PostPushToken(token, deviceId) {
		try {
			const result = yield authorizedFetch(`${PUSH_REGISTRATION_API_URL}/register`, { deviceId, token })
			if (result === 'Success') return result
			else {
				const e = new Error('Invalid data from token registration API')
				throw e
			}
		} catch (error) {
			throw error
		}
	},

	// We handle accessToken stuff here manually because the user is signing out and we are
	// losing the accessToken, so it has to be provided manually for us.
	* DeletePushToken(token, accessToken) {
		try {
			yield fetch(`${PUSH_REGISTRATION_API_URL}/token/${encodeURIComponent(token)}`, {
				method: 'DELETE',
				headers: { 'Authorization': `Bearer ${accessToken}` }
			})
		} catch (error) {
			throw error
		}
	}
}

export default MyMessagesService
