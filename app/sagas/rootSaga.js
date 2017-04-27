import { fork } from 'redux-saga/effects';
import surveySaga from './surveySaga';
import cardSaga from './cardSaga';
import locationSaga from './locationSaga';
import shuttleSaga from './shuttleSaga';
import diningSaga from './diningSaga';
import dataSaga from './dataSaga';
import homeSaga from './homeSaga';
import conferenceSaga from './conferenceSaga';

// single entry point to start all Sagas at once
export default function* rootSaga() {
	yield [
		fork(surveySaga),
		fork(cardSaga),
		fork(locationSaga),
		fork(shuttleSaga),
		fork(diningSaga),
		fork(dataSaga),
		fork(homeSaga),
		fork(conferenceSaga),
	];
}
