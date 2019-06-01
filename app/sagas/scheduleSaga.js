import {
	call,
	put,
	select,
	takeLatest
} from 'redux-saga/effects'

import ScheduleService from '../services/scheduleService'
import schedule from '../util/schedule'
import logger from '../util/logger'
import { SCHEDULE_TTL } from '../AppSettings'

const getSchedule = state => (state.schedule)
const getUserData = state => (state.user)

function* updateSchedule() {
	const { lastUpdated, data, currentTerm } = yield select(getSchedule)
	const { isLoggedIn, profile } = yield select(getUserData)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated

	if (
		isLoggedIn &&
		profile.classifications.student &&
		(
			(currentTerm && currentTerm.term_code !== 'inactive' && !data) ||
			timeDiff > SCHEDULE_TTL
		)
	) {
		try {
			yield put({ type: 'GET_SCHEDULE_REQUEST' })
			const term = yield call(ScheduleService.FetchTerm)
			if (term) {
				yield put({ type: 'SET_SCHEDULE_TERM', term })

				const scheduleData = yield call(ScheduleService.FetchSchedule, term.term_code)
				if (scheduleData) {
					yield put({ type: 'SET_SCHEDULE', schedule: scheduleData })
					yield put({ type: 'GET_SCHEDULE_SUCCESS' })
				}
				yield put({ type: 'UPDATE_SI_SESSIONS' })

				// check for finals
				const parsedScheduleData = schedule.getData(scheduleData)
				const finalsData = schedule.getFinals(parsedScheduleData)
				const finalsArray = []
				Object.keys(finalsData).forEach((day) => {
					if (finalsData[day].length > 0) {
						finalsArray.push({
							day,
							data: finalsData[day]
						})
					}
				})
				if (finalsArray.length > 0) {
					// check if finals are active
					yield put({ type: 'GET_FINALS_REQUEST' })
					try {
						const finalsActive = yield call(ScheduleService.FetchFinals)
						if (finalsActive) {
							yield put({ type: 'SHOW_CARD', id: 'finals' })
						} else {
							yield put({ type: 'HIDE_CARD', id: 'finals' })
						}
						yield put({ type: 'GET_FINALS_SUCCESS' })
					} catch (error) {
						yield put({ type: 'GET_FINALS_FAILURE', error })
						throw error
					}
				}
			} else {
				// There is no term
				const inactiveTerm = {
					term_name: 'No Term',
					term_code: 'inactive'
				}

				yield put({ type: 'SET_SCHEDULE_TERM', term: inactiveTerm })
				yield put({ type: 'SET_SCHEDULE', schedule: null })
				yield put({ type: 'HIDE_CARD', id: 'finals' })
				yield put({ type: 'GET_SCHEDULE_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_SCHEDULE_FAILURE', error })
			logger.trackException(error)
		}
	}
}

function* populateClassArray(scheduleData) {
	yield put({ type: 'POPULATE_CLASS_ARRAY' })
}

function* scheduleSaga() {
	yield takeLatest('UPDATE_SCHEDULE', updateSchedule)
	yield takeLatest('POPULATE_CLASS', populateClassArray)
}

export default scheduleSaga
