import { delay } from 'redux-saga';
import { put, takeLatest, call, select } from 'redux-saga/effects';
import Permissions from 'react-native-permissions';
import logger from '../util/logger';
import WeatherService from '../services/weatherService';
import { WEATHER_API_TTL } from '../AppSettings';

const getWeather = (state) => (state.weather);

function* watchData() {
	while (true) {
		try {
			yield call(updateWeather);
		} catch (err) {
			console.log(err);
		}
		yield delay(60000); // wait 5s
	}
}

function* updateWeather() {
	const { lastUpdated, data } = yield select(getWeather);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const weatherTTL = WEATHER_API_TTL * 1000;

	if (timeDiff < weatherTTL && data) {
		// Do nothing, no need to fetch new data
	} else {
		const weather = yield call(WeatherService.FetchWeather)
		yield put({ type: 'SET_WEATHER', weather });
	}
}

function* dataSaga() {
	yield call(watchData);
}

export default dataSaga;
