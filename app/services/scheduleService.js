const AppSettings = require('../AppSettings')

const ScheduleService = {
	FetchSchedule(accessToken) {
		return fetch(AppSettings.SCHEDULE_API_URL, {
			headers: {
				'Authorization': 'Bearer ' + accessToken
			}
		})
		.then(response => (response.json()))
		.catch((err) => {
			console.log('Error fetching courses:', err)
			return null
		})
	}
}

export default ScheduleService
