import { put, takeLatest } from 'redux-saga/effects'

function* updateParkingLotSelection(action) {
	yield* setLocalParkingLotSelections(action.index, action.value)
	yield* syncLotsWithProfile(action.selectedLots)
}

function* setLocalParkingLotSelections(index, value) {
	yield put({ type: 'SET_PARKING_LOT_SELECTION', index, value })
	yield put({ type: 'EDIT_LOCAL_LOT_SELECTION' })
}

function* syncLotsWithProfile(selectedLots) {
	const profileItems = { selectedLots }
	console.log(this)
	yield put({ type: 'MODIFY_LOCAL_PROFILE', profileItems })
}

function* parkingSaga() {
	yield takeLatest('UPDATE_PARKING_LOT_SELECTIONS', updateParkingLotSelection)
}

export default parkingSaga
