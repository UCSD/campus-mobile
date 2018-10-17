import { authorizedFetch } from '../util/auth'

const {
	TOPICS_API_URL,
	MYMESSAGES_API_URL,
	MESSAGES_TOPICS_URL,
	MP_REGISTRATION_API_URL,
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

	* FetchTopicMessages(topics, timestamp) {
		let userTopics = ''
		if (topics.length > 0) {
			topics.forEach((topic, index, arr) => {
				// Handle push / Firebase messaging
				if (index !== arr.length - 1) {
					userTopics += `${topic},`
				} else {
					userTopics += `${topic}`
				}
			})
		}


		let query = '&start=' + new Date().getTime()
		if (timestamp) query = '&start=' + timestamp

		try {
			const messages = yield (yield fetch(`${TOPICS_API_URL}?topics=${userTopics}${query}`)).json()
			if (messages && messages.messages) return messages
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
			const result = yield authorizedFetch(`${MP_REGISTRATION_API_URL}/register`, { deviceId, token })
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
			yield fetch(`${MP_REGISTRATION_API_URL}/token/${encodeURIComponent(token)}`, {
				method: 'DELETE',
				headers: { 'Authorization': `Bearer ${accessToken}` }
			})
		} catch (error) {
			throw error
		}
	}
}

export default MyMessagesService
