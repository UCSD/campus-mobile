import { put, takeLatest } from 'redux-saga/effects'

function* updateNotificationsState(action) {
	yield put({ type: 'SET_NOTIFICATION_STATE', isActive: action.isActive })
}

function* notificationsSaga() {
	yield takeLatest('UPDATE_NOTIFICATION_STATE', updateNotificationsState)
}

export default notificationsSaga