import {
	call,
	put,
	select,
	takeLatest
} from 'redux-saga/effects'
import logger from '../util/logger'

import StudentIDService from '../services/studentIDService'

// const getStudentProfile = state => (state.studentProfile)
const getUserData = state => (state.user)

function* updateStudentProfile() {
	const { isLoggedIn, profile } = yield select(getUserData)

	if (isLoggedIn && profile.classifications.student) {
		try {
			yield put({ type: 'GET_STUDENT_PROFILE_REQUEST' })
			const data = yield call(StudentIDService.FetchUserProfile)
			if (data) {
				yield put({ type: 'SET_STUDENT_PROFILE', studentProfile: data })
			}
		} catch (error) {
			yield put({ type: 'GET_STUDENT_PROFILE_FAILURE', error })
			logger.trackException(error)
		}
	}
}

function* myStudentProfileSaga() {
	yield takeLatest('UPDATE_STUDENT_PROFILE', updateStudentProfile)
}

export default myStudentProfileSaga

