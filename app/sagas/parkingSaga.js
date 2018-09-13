import { put, takeLatest } from 'redux-saga/effects'

function* updateParkingTypeSelection(action) {
	yield put({ type: 'SET_PARKING_TYPE_SELECTION', isChecked: action.isChecked, count: action.count })
}

function* parkingSaga() {
	yield takeLatest('UPDATE_PARKING_TYPE_SELECTION', updateParkingTypeSelection)
}

export default parkingSaga
