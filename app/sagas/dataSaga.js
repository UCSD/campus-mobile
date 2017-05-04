import { delay } from 'redux-saga';
import { put, call, select } from 'redux-saga/effects';
import { Image } from 'react-native';

import WeatherService from '../services/weatherService';
import { fetchConference } from '../services/conferenceService';
import LinksService from '../services/quicklinksService';
import {
	WEATHER_API_TTL,
	SURF_API_TTL,
	CONFERENCE_TTL,
	QUICKLINKS_API_TTL
} from '../AppSettings';

const getWeather = (state) => (state.weather);
const getSurf = (state) => (state.surf);
const getConference = (state) => (state.conference);
const getLinks = (state) => (state.links);

function* watchData() {
	while (true) {
		try {
			yield call(updateWeather);
			yield call(updateSurf);
			yield call(updateConference);
			yield call(updateLinks);
			yield put({ type: 'UPDATE_DINING' });
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

function* updateLinks() {
	const { lastUpdated, data } = yield select(getLinks);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const linksTTL = QUICKLINKS_API_TTL * 1000;

	if ((timeDiff < linksTTL) && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const links = yield call(LinksService.FetchQuicklinks);
		yield put({ type: 'SET_LINKS', links });

		if (links) {
			prefetchLinkImages(links);
		}
	}
}

function prefetchLinkImages(links) {
	links.forEach((item) => {
		const imageUrl = item.icon;
		// Check if actually a url and not icon name
		if (imageUrl.indexOf('fontawesome:') !== 0) {
			Image.prefetch(imageUrl);
		}
	});
}

function* dataSaga() {
	yield call(watchData);
}

export default dataSaga;
