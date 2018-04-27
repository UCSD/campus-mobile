import { delay } from 'redux-saga';
import { call, put, takeLatest } from 'redux-saga/effects';

import { postSurvey } from '../services/surveyService';

function* submitSurvey(action) {
	yield put({ type: 'SURVEY_DONE', id: action.id });

	// Keep trying to post answer, until success
	while (true) {
		try {
			const post = yield call(postSurvey, action.id, action.answer, action.data);
			return post;
		} catch (error) {
			delay(5000); // wait 5s
		}
	}
}

function* surveySaga() {
	yield takeLatest('SURVEY_SUBMITTED', submitSurvey);
}

export default surveySaga;
