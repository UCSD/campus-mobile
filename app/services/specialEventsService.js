import { SPECIAL_EVENT_API_URL } from '../AppSettings';

export function fetchSpecialEvents() {
	return fetch(SPECIAL_EVENT_API_URL, {
		method: 'get',
		dataType: 'json',
		headers: {
			'Accept': 'application/json',
			'Content-Type': 'application/json'
		}
	})
	.then((response) => response.json())
	.then((responseData) => responseData)
	.catch((err) => console.log('Error fetching specialEvents: ' + err)); // TODO, figure out final form of JSON
}