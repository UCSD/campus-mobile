import { CAMPUS_LISA_URL } from '../AppSettings';

export function fetchSchedule() {
	return fetch(CAMPUS_LISA_URL, {
		method: 'get',
		dataType: 'json',
		headers: {
			'Accept': 'application/json',
			'Content-Type': 'application/json'
		}
	})
	.then((response) => response.json())
	.then((responseData) => responseData.schedule); // TODO, figure out final form of JSON
}
