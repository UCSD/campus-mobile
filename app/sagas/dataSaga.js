import { delay } from 'redux-saga';
import { put, call, select } from 'redux-saga/effects';
import WeatherService from '../services/weatherService';
import { fetchSchedule } from '../services/conferenceService';
import { WEATHER_API_TTL, SURF_API_TTL } from '../AppSettings';

const getWeather = (state) => (state.weather);
const getSurf = (state) => (state.surf);

function* watchData() {
	while (true) {
		try {
			yield call(updateWeather);
			yield call(updateSurf);
			yield call(updateConference);
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
		const weather = yield call(WeatherService.FetchWeather);
		yield put({ type: 'SET_WEATHER', weather });
	}
}

function* updateSurf() {
	const { lastUpdated, data } = yield select(getSurf);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = SURF_API_TTL * 1000;

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		const surf = yield call(WeatherService.FetchSurf);
		yield put({ type: 'SET_SURF', surf });
	}
}

function* updateConference() {
	/*const { lastUpdated, data } = yield select(getSurf);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = SURF_API_TTL * 1000;

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {*/
		const schedule = yield call(fetchSchedule);
		yield put({ type: 'SET_CONFERENCE_SCHEDULE', schedule });
	// }
}

function* dataSaga() {
	yield call(watchData);
}

export default dataSaga;
