import { delay } from 'redux-saga';
import { put, call, select } from 'redux-saga/effects';
import WeatherService from '../services/weatherService';
import { fetchConference } from '../services/conferenceService';
import { WEATHER_API_TTL, SURF_API_TTL, CONFERENCE_TTL } from '../AppSettings';

const getWeather = (state) => (state.weather);
const getSurf = (state) => (state.surf);
const getConference = (state) => (state.conference);

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
	const { lastUpdated, data } = yield select(getConference);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = CONFERENCE_TTL * 1000;

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		const conference = yield call(fetchConference);
		yield put({ type: 'SET_CONFERENCE', conference });

		// Schedule has probably changed, so clear saved
		if (data && Object.keys(data).length !== Object.keys(conference)) {
			yield put({ type: 'CHANGED_CONFERENCE_SAVED', saved: [] });
		}
	}
}

function* dataSaga() {
	yield call(watchData);
}

export default dataSaga;
