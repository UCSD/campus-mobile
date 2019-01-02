import {
	call,
	put,
	takeLatest,
	race
} from 'redux-saga/effects'
import { delay } from 'redux-saga'
import FeedbackService from '../services/feedbackService'
import { HTTP_REQUEST_TTL } from '../AppSettings'
import logger from '../util/logger'

function* updateFeedback(action) {
	const { feedback } = action
	yield put({ type: 'SET_FEEDBACK_STATE', feedback })
}

function* postFeedback(action) {
	// We need to indicate that we're loading
	yield put({ type: 'POST_FEEDBACK_REQUEST' })

	try {
		const { response, timeout } = yield race({
			response: call(FeedbackService.FetchFeedback, action.feedback),
			timeout: call(delay, HTTP_REQUEST_TTL)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			throw e
		}
		else if (response.status !== 200) {
			const e = new Error('Invalid server response.')
			throw e
		}
		else {
			yield put({ type: 'SET_FEEDBACK_RESPONSE', response })
			yield put({ type: 'POST_FEEDBACK_SUCCESS' })
		}
	} catch (error) {
		logger.log(error)
		yield put({ type: 'POST_FEEDBACK_FAILURE', error })
	}
}

function* feedbackSaga() {
	yield takeLatest('UPDATE_FEEDBACK', updateFeedback)
	yield takeLatest('POST_FEEDBACK', postFeedback)
}

export default feedbackSaga
