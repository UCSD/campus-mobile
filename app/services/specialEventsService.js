import { SPECIAL_EVENT_API_URL } from '../AppSettings'

const SpecialEventsService = {
	FetchSpecialEvents() {
		return fetch(SPECIAL_EVENT_API_URL, {
			headers: { 'Cache-Control': 'no-cache' }
		})
			.then(response => response.json())
			.then(responseData => responseData)
			.catch(err => console.log('Error fetching specialEvents: ' + err))
	}
}

export default SpecialEventsService