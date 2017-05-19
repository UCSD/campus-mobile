import { delay } from 'redux-saga';
import { put, call, select } from 'redux-saga/effects';
import { Image } from 'react-native';

import WeatherService from '../services/weatherService';
import { fetchConference } from '../services/conferenceService';
import { fetchSurveyIds, fetchSurveyById } from '../services/surveyService';
import LinksService from '../services/quicklinksService';
import EventService from '../services/eventService';
import {
	WEATHER_API_TTL,
	SURF_API_TTL,
	CONFERENCE_TTL,
	QUICKLINKS_API_TTL,
	EVENTS_API_TTL
} from '../AppSettings';

const getWeather = (state) => (state.weather);
const getSurf = (state) => (state.surf);
const getConference = (state) => (state.conference);
const getLinks = (state) => (state.links);
const getSurvey = (state) => (state.survey);
const getEvents = (state) => (state.events);

function* watchData() {
	while (true) {
		try {
			yield call(updateWeather);
			yield call(updateSurf);
			yield call(updateConference);
			yield call(updateLinks);
			yield call(updateEvents);
			yield call(updateSurveys);
			yield put({ type: 'UPDATE_DINING' });
		} catch (err) {
			console.log(err);
		}
		yield delay(60000); // wait 1min
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

function* updateEvents() {
	const { lastUpdated, data } = yield select(getEvents);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = EVENTS_API_TTL * 1000;

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const events = yield call(EventService.FetchEvents);
		yield put({ type: 'SET_EVENTS', events });
	}
}

function* updateSurveys() {
	// TODO: SurveyTTL
	const { allIds } = yield select(getSurvey);

	// Fetch for all survey ids
	const surveyIds = yield call(fetchSurveyIds);

	if (surveyIds && surveyIds.length > allIds.length) {
		// Fetch each new survey
		for (let i = 0; i < surveyIds.length; ++i) {
			const id = surveyIds[i];
			if (allIds.indexOf(id) < 0) {
				const survey = yield call(fetchSurveyById, id);
				yield put({ type: 'SET_SURVEY', id, survey });
			}
		}
		yield put({ type: 'SET_SURVEY_IDS', surveyIds });
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
