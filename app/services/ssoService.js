import {
	parseString,
	Builder
} from 'xml2js';

import { Buffer } from 'buffer';



const TestService = {
	FetchIDPToken() {
		// encode client_id
		let formBody = [];
		const encodedKey = encodeURIComponent('client_id');
		const encodedVal = encodeURIComponent(client_id);
		formBody.push(encodedKey + '=' + encodedVal);
		formBody = formBody.join('&');

		// First get response from SP
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
				const ecpResponseXML = ecpResponse._bodyText;
				const ecpCookie = ecpResponse.headers.map['set-cookie'];

				parseString(ecpResponseXML, (err, ecpResponseJSON) => {
					if (err) {
						console.log('ivanerror: ' + err);
						return null;
					} else {
						// pick out responseConsumerURL
						const responseConsumerURL = ecpResponseJSON['soap11:Envelope']['soap11:Header'][0]['paos:Request'][0].$.responseConsumerURL;

						// Make idpRequest
						delete ecpResponseJSON['soap11:Envelope']['soap11:Header']; // Remove soap header
						const builder = new Builder();
						const idpRequest = builder.buildObject(ecpResponseJSON);

						// Base 64 encode username + password
						const encoded = Buffer.from(username + ':' + password).toString('base64');

						// Post to IDP
						return fetch(IDP_URL, {
							method: 'POST',
							headers: {
								'Accept': 'text/html; application/vnd.paos+xml',
								'Authorization': 'Basic ' + encoded,
								'Content-Type': 'text/xml; charset=utf-8',
							},
							body: idpRequest
						})
						.then((idpResponse) => {
							const idpResponseXML = idpResponse._bodyText;
							parseString(idpResponseXML, (err2, idpResponseJSON) => {
								if (err2) {
									console.log('ivanidperr: ' + err2);
								} else {
									const assertionConsumerServiceURL = idpResponseJSON['soap11:Envelope']['soap11:Header'][0]['ecp:Response'][0].$.AssertionConsumerServiceURL;
									// Check if consumerURL matches
									if (responseConsumerURL === assertionConsumerServiceURL) {
										// Post to SP
										return fetch(assertionConsumerServiceURL, {
											method: 'POST',
											headers: {
												'Accept': 'text/html; application/vnd.paos+xml',
												'Content-Type': 'application/vnd.paos+xml',
											},
											body: idpResponseXML
										})
										.then((spResponse) => {
											console.log('spyes: ' + spResponse._bodyText);
										})
										.catch((error) => {

										});
									} else {
										// send soap fault? Ask if necessary
										console.log('ivanconsumererr');
									}
								}
							});
						})
						.catch((error) => {
							console.log('ivanidperror: ' + error);
						});
					}
				});
			} else {
				console.log('ecpwhat: ' + ecpResponse._bodyText);
			}
		})
		.catch((error) => {
			console.log('ivanecperror: ' + error);
		});
	}
};

export default TestService;
