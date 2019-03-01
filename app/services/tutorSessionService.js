import { authorizedFetch } from '../util/auth'

import AppSettings from '../AppSettings'
import logger from '../util/logger'

const TutorSessionService = {
	* FetchTutorSessions() {
		const data = []
		// Query api for tutoring sessions
		try {
			const sessions = JSON.parse(yield authorizedFetch(AppSettings.TUTOR_SERVICE_API_URL))
			if (sessions.data && Array.isArray(sessions.data)) {
				data.push(...sessions.data)
			}
		} catch (err) {
			logger.trackException(err, false)
		}
		return { data }
	},
}

export default TutorSessionService
