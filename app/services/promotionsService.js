import { PROMOTIONS_API_URL } from '../AppSettings'

const PromotionsService = {
	FetchPromotions() {
		return fetch(PROMOTIONS_API_URL, {
			headers: { 'Cache-Control': 'no-cache' }
		})
			.then(response => response.json())
			.then(responseData => responseData)
			.catch(err => console.log('Error fetching promotions: ' + err))
	}
}

export default PromotionsService