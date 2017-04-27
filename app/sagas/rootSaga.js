import { fork } from 'redux-saga/effects';
import surveySaga from './surveySaga';
<<<<<<< HEAD
import cardSaga from './cardSaga';
import locationSaga from './locationSaga';
import shuttleSaga from './shuttleSaga';
import diningSaga from './diningSaga';
import dataSaga from './dataSaga';
=======
import shuttleSaga from './shuttleSaga';
import homeSaga from './homeSaga';
>>>>>>> v5.1-hotfix

// single entry point to start all Sagas at once
export default function* rootSaga() {
	yield [
		fork(surveySaga),
<<<<<<< HEAD
		fork(cardSaga),
		fork(locationSaga),
		fork(shuttleSaga),
		fork(diningSaga),
		fork(dataSaga)
=======
		fork(shuttleSaga),
		fork(homeSaga),
>>>>>>> v5.1-hotfix
	];
}
