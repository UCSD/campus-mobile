import { delay } from 'redux-saga';
import { put, call, select } from 'redux-saga/effects';
import { Image } from 'react-native';

import WeatherService from '../services/weatherService';
import { fetchConference } from '../services/conferenceService';
import { fetchSurveyIds, fetchSurveyById } from '../services/surveyService';
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
const getSurvey = (state) => (state.survey);
const getCards = (state) => (state.cards);

function* watchData() {
	while (true) {
		try {
			yield call(updateWeather);
			yield call(updateSurf);
			yield call(updateConference);
			yield call(updateLinks);
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
	const { cards } = yield select(getCards);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = CONFERENCE_TTL * 1000;

	if (timeDiff > ttl) {
		const conference = yield call(fetchConference);
		yield put({ type: 'SET_CONFERENCE', conference });

		if (conference['start-time'] <= nowTime &&
			conference['end-time'] >= nowTime) {
			// set new conf data

			if (cards.conference.autoActivated === false) {
				// Initialize Conference for first time use
				// wipe saved data
				yield put({ type: 'CHANGED_CONFERENCE_SAVED', saved: [] });
				// set active to true
				yield put({ type: 'UPDATE_CARD_STATE', id: 'conference', state: true });
				// set autoActivated to true
				yield put({ type: 'UPDATE_AUTOACTIVATED_STATE', id: 'conference', state: true });
			} else if (cards.conference.active) {
				// wipe saved data if needed
				// TODO: actual comparator instead of length equality?
				if (data && Object.keys(data.schedule).length !== Object.keys(conference.schedule).length) {
					yield put({ type: 'CHANGED_CONFERENCE_SAVED', saved: [] });
				}
			} else {
				// do nothing since card is turned off
			}
		} else {

			// Deactivate card one time when the conference is over
			if (cards.conference.autoActivated) {
				// set active to false
				yield put({ type: 'UPDATE_CARD_STATE', id: 'conference', state: false });
				// set autoActivated to false
				yield put({ type: 'UPDATE_AUTOACTIVATED_STATE', id: 'conference', state: false });
			} else {
				// Auto-activated false, but manually re-enabled by user
				// Conference is over, do nothing
			}
		}
	}
}

function* updateLinks() {
	const { lastUpdated, data } = yield select(getLinks);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = QUICKLINKS_API_TTL * 1000;

	if ((timeDiff < ttl) && data) {
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
