import { authorizedFetch } from '../util/auth'

const AppSettings = require('../AppSettings')

const ScheduleService = {
	* FetchSchedule(term, isStudentDemo) {
		try {
			const data = []

			// Query api for undergrad classes
			const undergrad = JSON.parse(yield authorizedFetch(AppSettings.ACADEMIC_HISTORY_API_URL(isStudentDemo) +
				`?academic_level=UN&term_code=${term}`))
			// Add to data if there is class data
			if (undergrad.data && Array.isArray(undergrad.data)) {
				data.push(...undergrad.data)
			}

			// Query api for graduate classes
			if (!isStudentDemo) {
				const grad = JSON.parse(yield authorizedFetch(AppSettings.ACADEMIC_HISTORY_API_URL(isStudentDemo) +
					`?academic_level=GR&term_code=${term}`))
				// Add to data if there is class data
				if (grad.data && Array.isArray(grad.data)) {
					data.push(...grad.data)
				}
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

	FetchTerm(isStudentDemo) {
		return fetch(AppSettings.ACADEMIC_TERM_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((error) => { throw error })
	},

	FetchFinals(isStudentDemo) {
		return fetch(AppSettings.ACADEMIC_TERM_FINALS_API_URL(isStudentDemo))
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((error) => { throw error })
	}
}

export default ScheduleService
