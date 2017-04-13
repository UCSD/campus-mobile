import { fork } from 'redux-saga/effects';
import surveySaga from './surveySaga';
import shuttleSaga from './shuttleSaga';
import homeSaga from './homeSaga';

// single entry point to start all Sagas at once
export default function* rootSaga() {
	yield [
		fork(surveySaga),
		fork(shuttleSaga),
		fork(homeSaga),
	];
}
