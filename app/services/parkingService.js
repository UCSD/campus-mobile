const AppSettings = require('../AppSettings')

const ParkingService = {
	FetchParking() {
		return fetch(AppSettings.PARKING_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((err) => {
				console.log('Error fetching parking lots: ' + err)
				return null
			})
	},
}
export default ParkingService
