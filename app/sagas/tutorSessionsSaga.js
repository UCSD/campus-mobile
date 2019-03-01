import {
	call,
	put,
	select,
	takeLatest
} from 'redux-saga/effects'


import TutorSessionService from '../services/tutorSessionService'
import tutorSessions from '../util/tutorSessions'
import logger from '../util/logger'

const getSchedule = state => (state.schedule)
const getUserData = state => (state.user)

function* updateTutorSessions() {
	const { data, currentTerm } = yield select(getSchedule)
	const { isLoggedIn, profile } = yield select(getUserData)

	if (
		isLoggedIn &&
		profile.classifications.student &&
		(
			(currentTerm && currentTerm.term_code !== 'inactive' && !data)
		)
	) {
		try {
			yield put({ type: 'GET_TUTOR_SESSIONS_REQUEST' })
			const sessions = yield call(TutorSessionService.FetchTutorSessions)
			if (sessions) {
				const parsedSessions =  tutorSessions(sessions, data)
				console.log('parsedSession: ' + parsedSessions)
				yield put({ type: 'SET_TUTOR_SESSIONS', parsedSessions })
				yield put({ type: 'GET_TUTOR_SESSIONS_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_TUTOR_SESSIONS_FAILURE', error })
			logger.trackException(error)
		}
	}
}

function* tutorSessionSaga() {
	yield takeLatest('UPDATE_TUTOR_SESSIONS', updateTutorSessions)
}

export default tutorSessionSaga
