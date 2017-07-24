import { CAMPUS_LISA_URL } from '../AppSettings';

export function fetchSpecialEvents() {
	return fetch(CAMPUS_LISA_URL, {
		method: 'get',
		dataType: 'json',
		headers: {
			'Accept': 'application/json',
			'Content-Type': 'application/json'
		}
	})
	.then((response) => response.json())
	.then((responseData) => responseData.specialEvents)
	.catch((err) => console.log('Error fetching specialEvents: ' + err)); // TODO, figure out final form of JSON
}
