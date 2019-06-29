const AppSettings = require('../AppSettings')

const DiningService = {
	FetchDining() {
		return fetch(AppSettings.DINING_API_URL + '/locations', {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
			.then(response => (response.json()))
			.then((data) => {
				if (data.errorMessage) {
					throw (data.errorMessage)
				} else {
					return data
				}
			})
			.catch(err => console.log('Error:FetchDining:' + err))
	},

	FetchDiningMenu(id) {
		return fetch(AppSettings.DINING_API_URL + '/menu/' + id, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
			.then(response => (response.json()))
			.then((data) => {
				if (data.message) {
					throw (data.message)
				} else {
					return data
				}
			})
			.catch(err => console.log('Error:FetchDiningMenu:' + err))
	}
}

export default DiningService
