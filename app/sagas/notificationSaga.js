import { put, takeLatest } from 'redux-saga/effects'

function* updateNotificationsState(action) {
	yield put({ type: 'SET_NOTIFICATION_STATE', isActive: action.isActive })
}

function* updateParkingNotifications(action) {
	yield put({ type: 'SET_PARKING_NOTIFICATION_STATE', selected: action.selectedParking })
}
function* notificationsSaga() {
	yield takeLatest('UPDATE_NOTIFICATION_STATE', updateNotificationsState)
	yield takeLatest('UPDATE_PARKING_NOTIFICATION_STATE', updateParkingNotifications)
}

export default notificationsSaga