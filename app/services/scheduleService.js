import { authorizedFetch } from '../util/auth'

const AppSettings = require('../AppSettings')

const ScheduleService = {
	FetchSchedule() {
		return authorizedFetch(AppSettings.SCHEDULE_API_URL)
			.then((data) => {
				if (data.data) return data
				else {
					const e = new Error('Invalid data from schedule API')
					throw e
				}
			})
			.catch((error) => {
				throw error
			})
	}
}

export default ScheduleService
