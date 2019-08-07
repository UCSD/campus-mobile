import { put, call, takeLatest, select, race } from 'redux-saga/effects'
import { delay } from 'redux-saga'
import OccuspaceService from '../services/occuspaceService'
import logger from '../util/logger'
import { OCCUSPACE_FETCH_TIMEOUT } from '../AppSettings'

const getOccuspaceData = state => (state.occuspace)
const getUserData = state => (state.user)

function* updateOccuspaceData() {
	// old data on device
	let { data }  = yield select(getOccuspaceData)
	try {
		yield put({ type: 'GET_OCCUSPACE_REQUEST' })
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
			logger.log(response)
			throw response.error
		} else {
			if (response) {
				const occuspaceData = JSON.parse(response)
				if (data) {
					data =  occuspaceData.sort(sortByOldOrder(data))
				} else {
					data = occuspaceData
				}
				yield put({ type: 'SET_OCCUSPACE_DATA', data })
				yield call(loadSavedLocations)
				yield put({ type: 'GET_OCCUSPACE_SUCESS' })
				yield put({ type: 'SHOW_CARD', id: 'occuspace' })
			}
		}
	} catch (error) {
		yield put({ type: 'GET_OCCUSPACE_FAILURE', error })
		logger.trackException(error)
	}
}

function* loadSavedLocations() {
	// get previously selected lots from users synced profile
	const userData = yield select(getUserData)
	const prevSlectedOccuspaceLocations = userData.profile.selectedOccuspaceLocations
	if (prevSlectedOccuspaceLocations) {
		yield put({ type: 'SYNC_OCCUSPACE_LOCATION_DATA', prevSlectedOccuspaceLocations })
	}
}

function* uploadSelectedLocations() {
	const { selectedLocations } = yield select(getOccuspaceData)
	const selectedOccuspaceLocations = selectedLocations
	const profileItems = { selectedOccuspaceLocations }
	yield put({ type: 'MODIFY_LOCAL_PROFILE', profileItems })
}

// comparator function to sort all the occuspace locations in the same order as the passed in occuspaceData
function sortByOldOrder(occuspaceData) {
	return function (a, b) {
		return occuspaceData.findIndex(x => x.locationName === a.locationName) - occuspaceData.findIndex(x => x.locationName === b.locationName)
	}
}

function* occuspaceSaga() {
	yield takeLatest('UPDATE_OCCUSPACE_DATA', updateOccuspaceData)
	yield takeLatest('UPLOAD_SELECTED_OCCUSPACE_LOCATIONS', uploadSelectedLocations)
}

export default occuspaceSaga
