const AppSettings = require('../AppSettings')

const mobileAuthService = {
	retrieveAccessToken(base64Secret) {
		return fetch(AppSettings.QA_MOBILE_API_URL, {
			method: 'POST',
			headers: {
				'Authorization': 'Basic ' + base64Secret ,
				'content-type': 'application/x-www-form-urlencoded'
			},
			body: 'grant_type=client_credentials'
		})
			.then(response => (response.json()))
			.then((data) => {
				if (data.error) {
					throw new Error('Client Authentication failed.')
				} else {
					if (data.access_token && data.expires_in) {
						return data
					} else {
						throw new Error('Invalid response from server.')
					}
				}
			})
			.catch((err) => {
				console.log(err)
				throw new Error('Client Authentication failed.')
			})
	}
}

export default mobileAuthService
