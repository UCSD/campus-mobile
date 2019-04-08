import { authorizedFetch } from '../util/auth'
import logger from '../util/logger'


import { MY_STUDENT_PROFILE_API_URL, MY_STUDENT_CONTACT_API_URL } from '../AppSettings'

const StudentIDService = {
	* FetchStudentProfile() {
		// fetch profile
		try {
			const profile = yield authorizedFetch(MY_STUDENT_PROFILE_API_URL + '/profile')
			if (profile) {
				return profile
			}
		} catch (err) {
			logger.trackException(err, false)
		}
	},
	* FetchStudentName() {
		// fetch name
		try {
			const name = yield authorizedFetch(MY_STUDENT_CONTACT_API_URL + '/name')
			if (name) {
				return name
			}
		} catch (err) {
			logger.trackException(err, false)
		}
	},
	* FetchStudentPhoto() {
		// fetch image
		try {
			const imageUrl = yield authorizedFetch(MY_STUDENT_CONTACT_API_URL + '/photo')
			if (imageUrl) {
				return imageUrl
			}
		} catch (err) {
			logger.trackException(err, false)
		}
	}
}

export default StudentIDService