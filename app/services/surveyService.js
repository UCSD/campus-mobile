import logger from '../util/logger';

export function postSurvey(id, answer, data) {
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
			logger.log('Error submitting survey(' + id + '): ' + error);
			resolve(false);
		});
	});*/
}

export function fetchSurveyIds() {
	const fakeData = ['s1', 's2'];

	return new Promise((resolve, reject) => {
		resolve(fakeData);
	});
}

export function fetchSurveyById(id) {
	const fakeData = {
		byId: {
			's1': {
				id: 's1',
				question: 'Should UC San Diego make its new mascot the puffer fish?'
			},
			's2': {
				id: 's2',
				question: 'Should UC San Diego make its new mascot the cat fish?'
			}
		},
		allIds: ['s1', 's2']
	};

	return new Promise((resolve, reject) => {
		resolve(fakeData.byId[id]);
	});
}
