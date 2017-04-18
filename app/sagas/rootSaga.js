import { fork } from 'redux-saga/effects';
import surveySaga from './surveySaga';
import cardSaga from './cardSaga';
import homeSaga from './homeSaga';
import shuttleSaga from './shuttleSaga';
import diningSaga from './diningSaga';

// single entry point to start all Sagas at once
export default function* rootSaga() {
	yield [
		fork(surveySaga),
		fork(cardSaga),
		fork(homeSaga),
		fork(shuttleSaga),
		fork(diningSaga)
	];
}
