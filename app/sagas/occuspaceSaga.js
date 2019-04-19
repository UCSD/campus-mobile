import { put, call, takeLatest } from 'redux-saga/effects'
import OccuspaceService from '../services/occuspaceService'
import logger from '../util/logger'

function* updateOccuspaceData(action) {
	try {
		const occuspaceData = yield call(OccuspaceService.FetchOccuspace)
		if (occuspaceData) {
			yield put({ type: 'SET_OCCUSPACE_DATA', occuspaceData })
		}
	} catch (error) {
		logger.trackException(error)
	}
}

function* occuspaceSaga() {
	yield takeLatest('UPDATE_OCCUSPACE_DATA', updateOccuspaceData)
}

export default occuspaceSaga
