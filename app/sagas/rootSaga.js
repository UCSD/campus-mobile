import { all, fork } from 'redux-saga/effects'
import cardSaga from './cardSaga'
import locationSaga from './locationSaga'
import shuttleSaga from './shuttleSaga'
import diningSaga from './diningSaga'
import dataSaga from './dataSaga'
import homeSaga from './homeSaga'
import specialEventsSaga from './specialEventsSaga'
import userSaga from './userSaga'
import mapSaga from './mapSaga'
import feedbackSaga from './feedbackSaga'
import routesSaga from './routesSaga'
import scheduleSaga from './scheduleSaga'
import parkingSaga from './parkingSaga'
import messagesSaga from './messagesSaga'
import siSessionsSaga from './siSessionsSaga'
import courseSaga from './courseSaga'

// single entry point to start all Sagas at once
export default function* rootSaga() {
	yield all([
		fork(cardSaga),
		fork(locationSaga),
		fork(shuttleSaga),
		fork(diningSaga),
		fork(dataSaga),
		fork(homeSaga),
		fork(routesSaga),
		fork(specialEventsSaga),
		fork(userSaga),
		fork(mapSaga),
		fork(feedbackSaga),
		fork(scheduleSaga),
		fork(parkingSaga),
		fork(messagesSaga),
		fork(siSessionsSaga),
		fork(courseSaga)
	])
}
