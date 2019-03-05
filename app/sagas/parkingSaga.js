import { put, takeLatest, select } from 'redux-saga/effects'

const getParkingData = state => (state.parking)

function* updateParkingLotSelection(action) {
	yield* setLocalParkingLotSelections(action.name, action.add)
	yield* syncLocalLotsSelection()
}

// add is a boolean that determins if we are unselcting the parking lot or selecting it
function* setLocalParkingLotSelections(name, add) {
	yield put({ type: 'SET_PARKING_LOT_SELECTION', name, add })
}

function* syncLocalLotsSelection() {
	const { selectedLots } = yield select(getParkingData)
	const profileItems = { selectedLots }
	yield put({ type: 'MODIFY_LOCAL_PROFILE', profileItems })
}

function* reorderParkingLots(action) {
	const { newParkingData } = action
	yield put({ type: 'SET_PARKING_DATA', newParkingData })
}

function* parkingSaga() {
	yield takeLatest('UPDATE_PARKING_LOT_SELECTIONS', updateParkingLotSelection)
	yield takeLatest('REORDER_PARKING_LOTS', reorderParkingLots )
}

export default parkingSaga
