import { authorizedFetch } from '../util/auth'
import AppSettings from '../AppSettings'

const ScheduleService = {
	* FetchSchedule(term) {
		try {
			/** TODO: Use affiliate attribute to determine academic_level **/
			// GR_API_URL = AppSettings.ACADEMIC_HISTORY_API_URL + '?academic_level=GR&term_code=' + term
			const scheduleData = JSON.parse(yield authorizedFetch(AppSettings.ACADEMIC_HISTORY_API_URL + '?academic_level=UN&term_code=' + term))
			return { scheduleData }
		} catch (err) {
			throw err
		}
	},

	FetchTerm() {
		return fetch(AppSettings.ACADEMIC_TERM_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((err) => { throw err })
	},

	FetchFinals() {
		return fetch(AppSettings.ACADEMIC_TERM_FINALS_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((err) => { throw err })
	}
}

export default ScheduleService
