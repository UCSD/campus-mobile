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
			const studentProfile = JSON.parse(yield call(StudentIDService.FetchStudentProfile))
			if (studentProfile) {
				yield put({ type: 'SET_STUDENT_PROFILE', profile: studentProfile })
				yield put({ type: 'GET_STUDENT_PROFILE_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_STUDENT_PROFILE_FAILURE', error })
			logger.trackException(error)
		}

		try {
			yield put({ type: 'GET_STUDENT_NAME_REQUEST' })
			const name = JSON.parse(yield call(StudentIDService.FetchStudentName))
			if (name) {
				yield put({ type: 'SET_STUDENT_NAME', name })
				yield put({ type: 'GET_STUDENT_NAME_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_STUDENT_NAME_FAILURE', error })
			logger.trackException(error)
		}
		try {
			yield put({ type: 'GET_STUDENT_BARCODE' })
			const studentBarcode = JSON.parse(yield call(StudentIDService.FetchStudentBarcode))
			if (studentBarcode) {
				yield put({ type: 'SET_STUDENT_BARCODE', barcode: studentBarcode })
				yield put({ type: 'GET_STUDENT_BARCODE_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_STUDENT_BARCODE_FAILURE', error })
			logger.trackException(error)
		}

		try {
			yield put({ type: 'GET_STUDENT_PHOTO_REQUEST' })
			const image = JSON.parse(yield call(StudentIDService.FetchStudentPhoto))
			if (image) {
				yield put({ type: 'SET_STUDENT_PHOTO', image })
				yield put({ type: 'GET_STUDENT_PHOTO_SUCCESS' })
			}
		} catch (error) {
			yield put({ type: 'GET_STUDENT_PHOTO_FAILURE', error })
			logger.trackException(error)
		}
	}
}

function* myStudentProfileSaga() {
	yield takeLatest('UPDATE_STUDENT_PROFILE', updateStudentProfile)
}

export default myStudentProfileSaga

