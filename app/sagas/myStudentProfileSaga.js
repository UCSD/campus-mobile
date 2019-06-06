import {
	all,
	call,
	put,
	select,
	takeLatest,
	race
} from 'redux-saga/effects'
import { delay } from 'redux-saga'
import logger from '../util/logger'
import { SID_CARD_TIMEOUT, SID_API_TTL } from '../AppSettings'
import StudentIDService from '../services/studentIDService'


// const getStudentProfile = state => (state.studentProfile)
const getUserData = state => (state.user)
const getStudentProfile =  state => (state.studentProfile)

function* updateStudentProfile() {
	const { lastUpdated, data } = yield select(getStudentProfile)
	const { isLoggedIn, profile } = yield select(getUserData)

	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const sidTTl = SID_API_TTL

	if (timeDiff < sidTTl && data) {
		// Do nothing, no need to fetch new data
	} else if (isLoggedIn && profile.classifications.student) {
		const fetchArray = [
			put({ type: 'GET_STUDENT_BARCODE_REQUEST' }),
			put({ type: 'GET_STUDENT_PROFILE_REQUEST' }),
			put({ type: 'GET_STUDENT_PHOTO_REQUEST' }),
			put({ type: 'GET_STUDENT_NAME_REQUEST' })
		]
		yield all(fetchArray)
	}
}

function* fetchStudentBarcode() {
	try {
		const { response, timeout } = yield race({
			response: call(StudentIDService.FetchStudentBarcode),
			timeout: call(delay, SID_CARD_TIMEOUT)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			throw e
		} else if (JSON.parse(response)) {
			const studentBarcode = JSON.parse(response)
			yield put({ type: 'SET_STUDENT_BARCODE', barcode: studentBarcode })
			yield put({ type: 'GET_STUDENT_BARCODE_SUCCESS' })
		}
	} catch (error) {
		yield put({ type: 'GET_STUDENT_PHOTO_FAILURE', error })
		logger.trackException(error)
	}
}
function* fetchStudentPhoto() {
	try {
		const { response, timeout } = yield race({
			response: call(StudentIDService.FetchStudentPhoto),
			timeout: call(delay, SID_CARD_TIMEOUT)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			throw e
		} else if (JSON.parse(response)) {
			const image = JSON.parse(response)
			yield put({ type: 'SET_STUDENT_PHOTO', image })
			yield put({ type: 'GET_STUDENT_PHOTO_SUCCESS' })
		}
	} catch (error) {
		yield put({ type: 'GET_STUDENT_PHOTO_FAILURE', error })
		logger.trackException(error)
	}
}
function* fetchStudentName() {
	try {
		const { response, timeout } = yield race({
			response: call(StudentIDService.FetchStudentName),
			timeout: call(delay, SID_CARD_TIMEOUT)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			throw e
		} else if (JSON.parse(response)) {
			const name = JSON.parse(response)
			yield put({ type: 'SET_STUDENT_NAME', name })
			yield put({ type: 'GET_STUDENT_NAME_SUCCESS' })
		}
	} catch (error) {
		yield put({ type: 'GET_STUDENT_PHOTO_FAILURE', error })
		logger.trackException(error)
	}
}
function* fetchStudentProfile() {
	try {
		const { response, timeout } = yield race({
			response: call(StudentIDService.FetchStudentProfile),
			timeout: call(delay, SID_CARD_TIMEOUT)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			throw e
		} else if (JSON.parse(response)) {
			const studentProfile = JSON.parse(response)
			yield put({ type: 'SET_STUDENT_PROFILE', profile: studentProfile })
			yield put({ type: 'GET_STUDENT_PROFILE_SUCCESS' })
		}
	} catch (error) {
		yield put({ type: 'GET_STUDENT_PROFILE_FAILURE', error })
		logger.trackException(error)
	}
}
function* myStudentProfileSaga() {
	yield takeLatest('UPDATE_STUDENT_PROFILE', updateStudentProfile)
	yield takeLatest('GET_STUDENT_PROFILE_REQUEST', fetchStudentProfile)
	yield takeLatest('GET_STUDENT_NAME_REQUEST', fetchStudentName)
	yield takeLatest('GET_STUDENT_BARCODE_REQUEST', fetchStudentBarcode)
	yield takeLatest('GET_STUDENT_PHOTO_REQUEST', fetchStudentPhoto)
}

export default myStudentProfileSaga

