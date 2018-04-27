import {
	parseString,
	Builder
} from 'xml2js';

import { Buffer } from 'buffer';


const client_encoded = Buffer.from(client_id + ':' + client_secret).toString('base64');

export default function getAPIToken(user, pass) {
	return fetchECPResponse().then((ecpResponse) =>
		processECPResponse(ecpResponse))
		.then((processedECP) =>
				fetchIDPResponse(user, pass, processedECP.idpRequest, processedECP.responseConsumerURL))
			.then((idpResponse) =>
				fetchAPIToken(idpResponse.assertionConsumerServiceURL, idpResponse.idpResponseXML))
				.then((apiToken) =>
					apiToken);
}

export function refreshAPIToken(apiToken) {
	const refreshData = {
		'grant_type': 'refresh_token',
		'refresh_token': apiToken.refresh_token,
		'scope': 'PRODUCTION'
	};

	const encodedBody = encodeFormBody(refreshData);

	return fetch(REFRESH_URL, {
		method: 'POST',
		headers: {
			'Accept': 'application/json',
			'Authorization': 'Basic ' + client_encoded,
			'Content-Type': 'application/x-www-form-urlencoded',
		},
		body: encodedBody
	})
	.then((refreshResponse) => refreshResponse.json())
	.catch((error) => {
		return null;
	});
}

function fetchECPResponse() {
	// encode client_id
	const formBody = encodeFormBody({ client_id });

	// First get response from SP
	// Normally I would need to be saving the cookie and sending
	// But RN seems to handle saving the cookie and sending it
	// This causes a bit of issue with calling this method again
	// todo, figure out good way to clear cookies
	return fetch(ECP_URL, {
		method: 'POST',
		headers: {
			'Accept': 'text/html; application/vnd.paos+xml',
			'Paos': 'ver=\\"urn:liberty:paos:2003-08\\";\\"urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp\\"',
			'Content-Type': 'application/x-www-form-urlencoded',
		},
		body: formBody
	})
	.then((ecpResponse) => {
		if (ecpResponse.ok) {
			return ecpResponse;
		} else {
			console.log('ecpwhat: ' + ecpResponse._bodyText);
			return null;
		}
	})
	.catch((error) => {
		console.log('ivanecperror: ' + error);
		return null;
	});
}

function processECPResponse(ecpResponse) {
	return new Promise((resolve, reject) => {
		if (ecpResponse !== null) {
			const ecpResponseXML = ecpResponse._bodyText;
			parseString(ecpResponseXML, (err, ecpResponseJSON) => {
				if (err) {
					console.log('ivanprocesserror: ' + err);
					reject(null);
				} else {
					// pick out responseConsumerURL
					const responseConsumerURL = ecpResponseJSON['soap11:Envelope']['soap11:Header'][0]['paos:Request'][0].$.responseConsumerURL;

					// Make idpRequest
					delete ecpResponseJSON['soap11:Envelope']['soap11:Header']; // Remove soap header
					const builder = new Builder();
					const idpRequest = builder.buildObject(ecpResponseJSON);

					resolve({ responseConsumerURL, idpRequest });
				}
			});
		} else {
			reject(null);
		}
	});
}

function fetchIDPResponse(user, pass, idpRequest, responseConsumerURL) {
	const encoded_auth = Buffer.from(user + ':' + pass).toString('base64');

	return fetch(IDP_URL, {
		method: 'POST',
		headers: {
			'Accept': 'text/html; application/vnd.paos+xml',
			'Authorization': 'Basic ' + encoded_auth,
			'Content-Type': 'text/xml; charset=utf-8',
		},
		body: idpRequest
	})
	.then((idpResponse) => {
		if (idpResponse.ok) {
			const idpResponseXML = idpResponse._bodyText;
			// validate URL
			return validateIDPResponse(idpResponseXML, responseConsumerURL)
				.then((assertionConsumerServiceURL) => {
					if (assertionConsumerServiceURL !== null) {
						return { assertionConsumerServiceURL, idpResponseXML };
					} else {
						// do something cuz assertion didn't pass?
						// or just do nothing
						return null;
					}
				});
		} else {
			console.log('ivanidpreserror: ' + idpResponse._bodyText);
			return null;
		}
	})
	.catch((error) => {
		console.log('ivanidperror: ' + error);
		return null;
	});
}

function validateIDPResponse(idpResponseXML, responseConsumerURL) {
	return new Promise((resolve, reject) => {
		parseString(idpResponseXML, (err, idpResponseJSON) => {
			if (err) {
				console.log('ivanidperr: ' + err);
				reject(null);
			} else {
				const assertionConsumerServiceURL = idpResponseJSON['soap11:Envelope']['soap11:Header'][0]['ecp:Response'][0].$.AssertionConsumerServiceURL;
				// Check if consumerURL matches
				if (responseConsumerURL === assertionConsumerServiceURL) {
					resolve(assertionConsumerServiceURL);
				} else {
					reject(null);
				}
			}
		});
	});
}

function fetchAPIToken(assertionConsumerServiceURL, idpResponseXML) {
	return fetch(assertionConsumerServiceURL, {
		method: 'POST',
		headers: {
			'Accept': 'application/json',
			'Content-Type': 'application/vnd.paos+xml',
		},
		body: idpResponseXML
	})
	.then((apiResponse) => apiResponse.json())
	.catch((error) => {

	});
}

function encodeFormBody(formObject) {
	// encode client_id
	let encodedBody = [];

	Object.keys(formObject).forEach((key) => {
		const encodeKey = encodeURIComponent(key);
		const encodeVal = encodeURIComponent(formObject[key]);
		encodedBody.push(encodeKey + '=' + encodeVal);
	});
	encodedBody = encodedBody.join('&');

	return encodedBody;
}
