import { put, takeLatest, select } from 'redux-saga/effects'

const getParkingData = state => (state.parking)

function* updateParkingLotSelection(action) {
	yield* setLocalParkingLotSelections(action.index, action.value)
	yield* syncLocalLotsSelection()
}

function* setLocalParkingLotSelections(index, value) {
	yield put({ type: 'SET_PARKING_LOT_SELECTION', index, value })
	yield put({ type: 'EDIT_LOCAL_LOT_SELECTION' })
}

function* syncLocalLotsSelection() {
	const { selectedLots } = yield select(getParkingData)
	const profileItems = { selectedLots }
	yield put({ type: 'MODIFY_LOCAL_PROFILE', profileItems })
}

function* parkingSaga() {
	yield takeLatest('UPDATE_PARKING_LOT_SELECTIONS', updateParkingLotSelection)
}

export default parkingSaga
