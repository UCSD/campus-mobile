import { put, call, takeLatest, select } from 'redux-saga/effects'
import OccuspaceService from '../services/occuspaceService'
import logger from '../util/logger'

const getOccuspaceData = state => (state.occuspace)
function* updateOccuspaceData() {
	// old data on device
	let { data }  = yield select(getOccuspaceData)
	try {
		// new data being fetched
		const occuspaceData = yield call(OccuspaceService.FetchOccuspace)
		if (occuspaceData) {
			if (data) {
				data =  occuspaceData.sort(sortByOldOrder(data))
			} else {
				data = occuspaceData
			}
			yield put({ type: 'SET_OCCUSPACE_DATA', data })
			yield put({ type: 'SHOW_CARD', id: 'occuspace' })
		}
	} catch (error) {
		logger.trackException(error)
	}
}

// comparator function to sort all the occuspace locations in the same order as the passed in occuspaceData
function sortByOldOrder(occuspaceData) {
	return function (a, b) {
		return occuspaceData.findIndex(x => x.locationName === a.locationName) - occuspaceData.findIndex(x => x.locationName === b.locationName)
	}
}

function* occuspaceSaga() {
	yield takeLatest('UPDATE_OCCUSPACE_DATA', updateOccuspaceData)
}

export default occuspaceSaga
