import logger from '../util/logger';

export default function postSurvey(id, answer, data) {
	return new Promise((resolve, reject) => {
		console.log('Survey: ' + id + ' Answer: ' + answer + ' Data: ' + JSON.stringify(data));
		resolve(true);
	});
	/*
	const SURVEY_URL = 'https://eforms.ucsd.edu/view.php?id=' + id;
	return new Promise((resolve, reject) => {
		fetch(SURVEY_URL, {
			method: 'POST',
		})
		.then((response) => {
			if (response.ok) {
				resolve(true);
			} else {
				resolve(false);
			}
		})
		.catch((error) => {
			logger.error('Error submitting survey(' + id + '): ' + error);
			resolve(false);
		});
	});*/
}

export function fetchSurveys() {
	const fakeData = {
		byId: {
			's1': {
				id: 's1',
				question: 'Should UC San Diego make its new mascot the puffer fish?'
			}
		},
		allIds: ['s1']
	};

	return fakeData;
}
