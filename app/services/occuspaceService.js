import { OCCUSPACE_API_URL_MOCK } from '../AppSettings'

const OccuspaceService = {
	FetchOccuspace() {
		return fetch(OCCUSPACE_API_URL_MOCK)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((err) => {
				console.log('Error fetching occuspace data: ' + err)
				return null
			})
	},
}

export default OccuspaceService