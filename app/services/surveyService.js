import logger from '../util/logger';

export default function postSurvey(id, answer, data) {
	const formData = new FormData();
	formData.append('element_5', answer); // Depending on eform setup these will be diff
	formData.append('element_1', JSON.stringify(data));
	formData.append('form_id', id);
	formData.append('submit_form','1');
	formData.append('page_number','1');
	formData.append('submit_form','Submit');

	const SURVEY_URL = 'https://eforms.ucsd.edu/view.php?id=' + id;
	return new Promise((resolve, reject) => {
		fetch(SURVEY_URL, {
			method: 'POST',
			body: formData
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
	});
}
