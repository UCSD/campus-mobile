const AppSettings = require('../AppSettings')

const ParkingService = {
	FetchParking() {
		const data = []
		AppSettings.PARKING_API_URLS.forEach((URL) => {
			fetch(URL)
				.then(response => response.json())
				.then(responseData => data.push(responseData))
				.catch((err) => {
					console.log('Error fetching parking data: ' + err)
				})
		})
		return data
	},
	FetchParkingLots() {
		return fetch(AppSettings.PARKING_LOTS_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((err) => {
				console.log('Error fetching parking lots: ' + err)
				return null
			})
	}
}

export default ParkingService
