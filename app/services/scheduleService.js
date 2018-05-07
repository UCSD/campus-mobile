import { authorizedFetch } from '../util/auth'

const AppSettings = require('../AppSettings')

const ScheduleService = {
	* FetchSchedule(term) {
		try {
			const data = yield authorizedFetch(AppSettings.ACADEMIC_HISTORY_API_URL + `&term_code=${term}`)
			if (data.data) return data
			else {
				const e = new Error('Invalid data from schedule API')
				throw e
			}
		} catch (error) {
			throw error
		}
	},

	FetchTerm() {
		return fetch(AppSettings.ACADEMIC_TERM_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch(err => console.log('Error fetching academic term: ' + err))
	}
}

export default ScheduleService
