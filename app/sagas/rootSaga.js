import { fork } from 'redux-saga/effects';
import surveySaga from './surveySaga';

// single entry point to start all Sagas at once
export default function* rootSaga() {
	yield [
		fork(surveySaga),
	];
}
