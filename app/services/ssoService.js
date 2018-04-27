const AppSettings = require('../AppSettings')

const ssoService = {
	retrieveAccessToken(loginInfo) {
		return fetch(AppSettings.SSO_ENDPOINT, {
			method: 'POST',
			headers: { 'Authorization': loginInfo }
		})
			.then(response => (response.json()))
			.then((data) => {
				if (data.errorMessage) {
					throw (data.errorMessage)
				} else {
					if (data.access_token && data.expiration) {
						return data
					} else {
						throw new Error('Invalid response from server.')
					}
				}
			})
			.catch((err) => {
				switch (err) {
					case AppSettings.SSO_CREDENTIALS_ERROR: {
						throw new Error('There was a problem with your credentials.')
					}
					default: {
						console.log(err)
						throw new Error('There was a problem signing in. Please try again later.')
					}
				}
			})
	}
}

export default ssoService
