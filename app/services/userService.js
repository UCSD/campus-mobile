import { authorizedFetch } from '../util/auth'

const { USER_PROFILE_API_URL } = require('../AppSettings')

const userService = {
	* FetchUserProfile() {
		try {
			const profile = JSON.parse(yield authorizedFetch(USER_PROFILE_API_URL))

			if (profile) return profile
			else {
				const e = new Error('Invalid data from profile API')
				throw e
			}
		} catch (error) {
			throw error
		}
	},

	* PostUserProfile(profile) {
		try {
			const result = yield authorizedFetch(`${USER_PROFILE_API_URL}`, profile)
			if (result === 'Success') return result
			else {
				const e = new Error('Invalid data from token registration API')
				throw e
			}
		} catch (error) {
			throw error
		}
	},
}

export default userService
