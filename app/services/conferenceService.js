import { CAMPUS_LISA_URL } from '../AppSettings';

export function fetchConference() {
	return fetch(CAMPUS_LISA_URL, {
		method: 'get',
		dataType: 'json',
		headers: {
			'Accept': 'application/json',
			'Content-Type': 'application/json'
		}
	})
	.then((response) => response.json())
	.then((responseData) => responseData.conference)
	.catch((err) => console.log('Error fetching conference: ' + err)); // TODO, figure out final form of JSON
}
