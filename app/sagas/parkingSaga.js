import { put, takeLatest } from 'redux-saga/effects'

function* updateParkingTypeSelection(action) {
	yield put({ type: 'UPDATE_PARKING_TYPE_SELECTION', isChecked: action.isChecked })
}

function* parkingSaga() {
	yield takeLatest('UPDATE_PARKING_TYPE_SELECTION', updateParkingTypeSelection)
}

export default parkingSaga
