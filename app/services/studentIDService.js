import { authorizedFetch } from '../util/auth'

import { MY_STUDENT_PROFILE_API_URL, MY_STUDENT_PROFILE_MOCK_API_URL } from '../AppSettings'

const StudentIDService = {
	* FetchUserProfile() {
		// const profile = yield authorizedFetch(MY_STUDENT_PROFILE_API_URL + '/profile')
		return yield fetch(MY_STUDENT_PROFILE_MOCK_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((err) => { throw err })
	},
}

export default StudentIDService