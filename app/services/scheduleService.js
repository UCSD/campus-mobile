import { authorizedFetch } from '../util/auth'

const AppSettings = require('../AppSettings')

const ScheduleService = {
	* FetchSchedule(term) {
		try {
			const data = []

			// Query api for undergrad classes
			const undergrad = yield authorizedFetch(AppSettings.ACADEMIC_HISTORY_API_URL +
				`?academic_level=UN&term_code=${term}`)
			// Add to data if there is class data
			if (undergrad.data) {
				data.push(...undergrad.data)
			}

			// Query api for graduate classes
			const grad = yield authorizedFetch(AppSettings.ACADEMIC_HISTORY_API_URL +
				`?academic_level=GR&term_code=${term}`)
			// Add to data if there is class data
			if (grad.data) {
				data.push(...grad.data)
			}

			if (data) return { data }
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
	},

	FetchFinals() {
		return fetch(AppSettings.ACADEMIC_TERM_API_URL + '/finals')
			.then(response => response.json())
			.then(responseData => responseData)
			.catch(err => console.log('Error fetching finals: ' + err))
	}
}

export default ScheduleService
