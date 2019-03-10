import {
	call,
	put,
	select,
	takeLatest
} from 'redux-saga/effects'


import siSessionService from '../services/siSessionService'
import siSchedule from '../util/siSchedule'
import logger from '../util/logger'

const getSchedule = state => (state.schedule)
const getUserData = state => (state.user)

function* updateSISessions() {
	const { data, currentTerm } = yield select(getSchedule)
	const { isLoggedIn, profile } = yield select(getUserData)
	if (
		isLoggedIn &&
		profile.classifications.student &&
		(
			(currentTerm && currentTerm.term_code !== 'inactive' && data)
		)
	) {
		try {
			yield put({ type: 'GET_SI_SESSIONS_REQUEST' })
			const sessions = yield call(siSessionService.FetchSISessions)
			if (sessions) {
				const parsedSessions =  siSchedule.getSessions(sessions, data)
				yield put({ type: 'SET_SI_SESSIONS', parsedSessions })
				yield put({ type: 'GET_SI_SESSIONS_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_SI_SESSIONS_FAILURE', error })
			logger.trackException(error)
		}
	}
}

function* siSessionSaga() {
	yield takeLatest('UPDATE_SI_SESSIONS', updateSISessions)
}

export default siSessionSaga
