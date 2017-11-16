import AppSettings from '../AppSettings';

// OpenID Authentication Provider
class OpenIDAuthentication {
	createAuthenticationUrl = () => {
		const openIdSettings = AppSettings.SSO.OPENID.OPTIONS;
		const authUrl = [
			`${openIdSettings.AUTH_URL}`,
			'?response_type=id_token+token',
			`&client_id=${openIdSettings.CLIENT_ID}`,
			`&redirect_uri=${openIdSettings.REDIRECT_URL}`,
			'&scope=openid+profile+email',
			`&state=${openIdSettings.STATE}`,
			`&nonce=${Math.random().toString(36).slice(2)}`
		].join('');

		return authUrl;
	}
	handleAuthenticationCallback = (event) => {
		const openIdSettings = AppSettings.SSO.OPENID.OPTIONS;

		// only handle callback URLs, in case we deep link for other things
		if (event.url.startsWith(openIdSettings.REDIRECT_URL)) {
			// get access_token, POST to userinfo endpoint to get back user info
			const accessRegex = event.url.match(/access_token=([^&]*)/);
			const stateRegex = event.url.match(/state=([^&]*)/);

			if (accessRegex && stateRegex) {
				// first, verify the state regex is what we expected
				if (stateRegex[1] !== openIdSettings.STATE) {
					return; // just don't handle the event, though maybe log error?
				}

				const access_token = accessRegex[1]; // just get the value from the match group

				return fetch(openIdSettings.USER_INFO_URL, {
					method: 'POST',
					headers: {
						'Authorization': `Bearer ${access_token}`,
					},
				})
				.then(result => result.json())
				.then(userInfo => Promise.resolve(userInfo));
			}
		}

		return Promise.reject({ message: 'could not validate login' });
	}
}

export default function getAuthenticationService() {
	return new OpenIDAuthentication();
}
