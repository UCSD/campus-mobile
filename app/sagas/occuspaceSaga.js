import { put, call, takeLatest } from 'redux-saga/effects'
import OccuspaceService from '../services/occuspaceService'
import logger from '../util/logger'
import { getLocationsMap } from '../util/occuspace'

const getOccuspaceData = state => (state.occuspace)
function* updateOccuspaceData() {
	try {
		let occuspaceData = yield call(OccuspaceService.FetchOccuspace)
		if (occuspaceData) {
			occuspaceData = yield getLocationsMap(occuspaceData)
			yield put({ type: 'SET_OCCUSPACE_DATA', occuspaceData })
		}
	} catch (error) {
		logger.trackException(error)
	}
}

function* addOccuspaceLocation(action) {
	const { selectedLocations } = yield call(getOccuspaceData)
	// check to see if location has already been added
	if (!selectedLocations.contains(action.location)) {
		selectedLocations.push(action.location)
		yield put({ action: 'SET_SELECTED_OCCUSPACE_LOCATIONS', selectedLocations })
	}
}

function* removeOccuspaceLocation(action) {
	const { selectedLocations } = yield call(getOccuspaceData)
	// check to see if location exists before removing it
	if (selectedLocations.contains(action.location)) {
		const index = selectedLocations.indexOf(action.location)
		selectedLocations.splice(index, 1)
		yield put({ action: 'SET_SELECTED_OCCUSPACE_LOCATIONS', selectedLocations })
	}
}

function* orderOccuspaceLocations(action) {
	const { selectedLocations } = action
	if (selectedLocations) {
		yield put({ action: 'SET_SELECTED_OCCUSPACE_LOCATIONS', selectedLocations })
	}
}

function* occuspaceSaga() {
	yield takeLatest('UPDATE_OCCUSPACE_DATA', updateOccuspaceData)
	yield takeLatest('ADD_OCCUSPACE_LOCATION', addOccuspaceLocation)
	yield takeLatest('REMOVE_OCCUSPACE_LOCATION', removeOccuspaceLocation)
	yield takeLatest('ORDER_OCCUSPACE_LOCATIONS', orderOccuspaceLocations)
}

export default occuspaceSaga
