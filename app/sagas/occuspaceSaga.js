import { put, call, takeLatest, select, race } from 'redux-saga/effects'
import { delay } from 'redux-saga'
import OccuspaceService from '../services/occuspaceService'
import logger from '../util/logger'
import { OCCUSPACE_FETCH_TIMEOUT } from '../AppSettings'

const getOccuspaceData = state => (state.occuspace)
function* updateOccuspaceData() {
	// old data on device
	let { data }  = yield select(getOccuspaceData)
	try {
		// new data being fetched
		const { response, timeout } = yield race({
			response: call(OccuspaceService.FetchOccuspace),
			timeout: call(delay, OCCUSPACE_FETCH_TIMEOUT)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			e.name = 'occuspaceTimeout'
			throw e
		} else if (response.error) {
			if (response.error) {
				logger.log(response)
				throw response.error
			}
		} else {
			if (response) {
				const occuspaceData = JSON.parse(response)
				if (data) {
					data =  occuspaceData.sort(sortByOldOrder(data))
				} else {
					data = occuspaceData
				}
				yield put({ type: 'SET_OCCUSPACE_DATA', data })
				yield put({ type: 'SHOW_CARD', id: 'occuspace' })
			}
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
