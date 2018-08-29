import { authorizedFetch } from '../util/auth'

const { MYMESSAGES_API_URL } = require('../AppSettings')

const MyMessagesService = {
	* FetchMyMessages(timestamp) {
		try {
			let query = '?start=' + new Date().getTime()
			if (timestamp) query = '?start=' + timestamp

			const messages = yield authorizedFetch(`${MYMESSAGES_API_URL}/messages${query}`)

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
			const messages = yield authorizedFetch(`${MYMESSAGES_API_URL}/topic/${topic}`)

			if (messages) return { messages }
			else {
				const e = new Error('Invalid data from messages API')
				throw e
			}
		} catch (error) {
			throw error
		}
	}
}

export default MyMessagesService
