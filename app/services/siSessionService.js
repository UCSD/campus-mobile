import AppSettings from '../AppSettings'

const siSessionService = {
	FetchSISessions() {
		return fetch(AppSettings.SI_SESSIONS_SERVICE_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((err) => {
				console.log('Error fetching SI sessions: ' + err)
				return null
			})
	}
}

export default siSessionService
