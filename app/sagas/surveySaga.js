import { delay } from 'redux-saga';
import { call, put, takeLatest } from 'redux-saga/effects';

import postSurvey from '../services/surveyService';

// 264935
function* submitSurvey(action) {
	while (true) {
		try {
			yield call(postSurvey, action.id, action.answer, action.data);
			yield put({ type: 'SURVEY_RECEIVED', id: action.id });
		} catch (error) {
			yield call(delay, 5000); // Retry in 5s
		}
	}
}

function* surveySaga() {
	yield takeLatest('SURVEY_SUBMITTED', submitSurvey);
}

export default surveySaga;
