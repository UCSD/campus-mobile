import { call, put, select, takeLatest, race } from 'redux-saga/effects';
import { delay } from 'redux-saga';
import FeedbackService from '../services/feedbackService';
import { FEEDBACK_POST_TTL } from '../AppSettings';
import logger from '../util/logger';

const getFeedback = (state) => (state.feedback);

function* updateFeedback(action) {
	const { status } = yield select(getFeedback);
	const newFeedback = action.feedback;
	newFeedback.status = status;
	yield put({ type: 'SET_FEEDBACK_STATE', newFeedback });
}

function* postFeedback(action) {
	// We need to indicate that we're loading
	const newFeedback = yield select(getFeedback);
	newFeedback.status = {
		requesting: true,
		timeRequested: new Date()
	};
	yield put({ type: 'SET_FEEDBACK_STATE', newFeedback });

	try {
		const { response, timeout } = yield race({
			response: call(FeedbackService.FetchFeedback, action.feedback),
			timeout: call(delay, FEEDBACK_POST_TTL)
		});

		if (timeout) {
			const e = new Error('Request timed out.');
			throw e;
		}
		else if (response.status !== 200) {
			logger.log(response);
			const e = new Error('Invalid server response.');
			throw e;
		}
		else {
			yield put({ type: 'FEEDBACK_POST_SUCCEEDED', response });
		}
	} catch (error) {
		logger.log(error);
		yield put({ type: 'FEEDBACK_POST_FAILED', error });
	}
}

function* feedbackSaga() {
	yield takeLatest('UPDATE_FEEDBACK_STATE', updateFeedback);
	yield takeLatest('FEEDBACK_POST_REQUESTED', postFeedback);
}

export default feedbackSaga;
