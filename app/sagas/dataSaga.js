import { delay } from 'redux-saga';
import { put, call, select } from 'redux-saga/effects';
import { Image } from 'react-native';

import WeatherService from '../services/weatherService';
import { fetchSpecialEvents } from '../services/specialEventsService';
import { fetchSurveyIds, fetchSurveyById } from '../services/surveyService';
import LinksService from '../services/quicklinksService';
import EventService from '../services/eventService';
import NewsService from '../services/newsService';
import emergencyAlertService from '../services/emergencyAlertService';
import { fetchMasterStopsNoRoutes, fetchMasterRoutes } from '../services/shuttleService';
import {
	WEATHER_API_TTL,
	SURF_API_TTL,
	SPECIAL_EVENTS_TTL,
	QUICKLINKS_API_TTL,
	EVENTS_API_TTL,
	NEWS_API_TTL,
	DATA_SAGA_TTL,
	SHUTTLE_MASTER_TTL,
	EMERGENCY_ALERT_TTL,
} from '../AppSettings';

const getWeather = (state) => (state.weather);
const getSurf = (state) => (state.surf);
const getSpecialEvents = (state) => (state.specialEvents);
const getLinks = (state) => (state.links);
const getSurvey = (state) => (state.survey);
const getEvents = (state) => (state.events);
const getNews = (state) => (state.news);
const getCards = (state) => (state.cards);
const getShuttle = (state) => (state.shuttle);
const getEmergencyAlerts = (state) => (state.emergencyAlerts)

function* watchData() {
	while (true) {
		try {
			yield call(updateWeather);
			yield call(updateSurf);
			yield call(updateSpecialEvents);
			yield call(updateLinks);
			yield call(updateEvents);
			yield call(updateNews);
			yield call(updateSurveys);
			yield call(updateShuttleMaster);
			yield put({ type: 'UPDATE_DINING' });
			yield call(updateEmergencyAlerts);
		} catch (err) {
			console.log(err);
		}
		yield delay(DATA_SAGA_TTL);
	}
}

function* updateShuttleMaster() {
	const { lastUpdated, routes, stops } = yield select(getShuttle);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const shuttleTTL = SHUTTLE_MASTER_TTL;

	if ((timeDiff < shuttleTTL) && (routes !== null) && (stops !== null)) {
		// Do nothing, don't need to update
	} else {
		// Fetch for new data
		const stopsData = yield call(fetchMasterStopsNoRoutes);
		const routesData = yield call(fetchMasterRoutes);

		// Set toggles
		const initialToggles = {};
		Object.keys(routesData).forEach((key, index) => {
			initialToggles[key] = false;
		});

		yield put({
			type: 'SET_SHUTTLE_MASTER',
			stops: stopsData,
			routes: routesData,
			toggles: initialToggles,
			nowTime
		});
	}
}

function* updateWeather() {
	const { lastUpdated, data } = yield select(getWeather);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const weatherTTL = WEATHER_API_TTL;

	if (timeDiff < weatherTTL && data) {
		// Do nothing, no need to fetch new data
	} else {
		const weather = yield call(WeatherService.FetchWeather);
		if (weather) {
			yield put({ type: 'SET_WEATHER', weather });
		}
	}
}

function* updateSurf() {
	const { lastUpdated, data } = yield select(getSurf);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = SURF_API_TTL;

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		const surf = yield call(WeatherService.FetchSurf);
		if (surf) {
			yield put({ type: 'SET_SURF', surf });
		}
	}
}

function* updateSpecialEvents() {
	const { lastUpdated, saved } = yield select(getSpecialEvents);
	const { cards } = yield select(getCards);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = SPECIAL_EVENTS_TTL;

	if (timeDiff > ttl && Array.isArray(saved)) {
		const specialEvents = yield call(fetchSpecialEvents);

		if (specialEvents) {
			prefetchSpecialEventsImages(specialEvents);
			if (specialEvents['start-time'] <= nowTime &&
				specialEvents['end-time'] >= nowTime) {
				// Inside active specialEvents window
				if (cards.specialEvents.autoActivated === false) {
					// Initialize SpecialEvents for first time use
					// wipe saved data
					yield put({ type: 'CHANGED_SPECIAL_EVENTS_SAVED', saved: [] });
					yield put({ type: 'CHANGED_SPECIAL_EVENTS_LABELS', labels: [] });
					yield put({ type: 'SET_SPECIAL_EVENTS', specialEvents });
					// set active and autoActivated to true
					yield put({ type: 'UPDATE_CARD_STATE', id: 'specialEvents', state: true });
					yield put({ type: 'UPDATE_AUTOACTIVATED_STATE', id: 'specialEvents', state: true });
				} else if (cards.specialEvents.active) {
					// remove any saved items that no longer exist
					if (saved.length > 0) {
						const stillsExists = yield call(savedExists, specialEvents.uids, saved);
						yield put({ type: 'CHANGED_SPECIAL_EVENTS_SAVED', saved: stillsExists });
						yield put({ type: 'CHANGED_SPECIAL_EVENTS_LABELS', labels: [] });
					}
					yield put({ type: 'SET_SPECIAL_EVENTS', specialEvents });
				}
			} else {
				// Outside active specialEvents window
				// Deactivate card one time when the specialEvents is over
				if (cards.specialEvents.autoActivated) {
					// set active and autoActivated to false
					yield put({ type: 'UPDATE_CARD_STATE', id: 'specialEvents', state: false });
					yield put({ type: 'UPDATE_AUTOACTIVATED_STATE', id: 'specialEvents', state: false });
				} else {
					// Auto-activated false, but manually re-enabled by user
					// SpecialEvents is over, do nothing
				}
			}
		}
	}
}

function* updateLinks() {
	const { lastUpdated, data } = yield select(getLinks);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = QUICKLINKS_API_TTL;

	if ((timeDiff < ttl) && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const links = yield call(LinksService.FetchQuicklinks);

		if (links) {
			yield put({ type: 'SET_LINKS', links });
			prefetchLinkImages(links);
		}
	}
}

function* updateEmergencyAlerts() {
	const { lastUpdated, data } = yield select(getEmergencyAlerts);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = EMERGENCY_ALERTS_TTL;

	if ((timeDiff < ttl) && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const links = yield call(LinksService.EmergencyAlertService);

		if (emergencyAlerts) {
			yield put({ type: 'SET_ALERTS', emergencyAlerts });
		}
	}
}

function* updateEvents() {
	const { lastUpdated, data } = yield select(getEvents);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = EVENTS_API_TTL;

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const events = yield call(EventService.FetchEvents);
		yield put({ type: 'SET_EVENTS', events });
	}
}

function* updateNews() {
	const { lastUpdated, data } = yield select(getNews);
	const nowTime = new Date().getTime();
	const timeDiff = nowTime - lastUpdated;
	const ttl = NEWS_API_TTL;

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const news = yield call(NewsService.FetchNews);
		yield put({ type: 'SET_NEWS', news });
	}
}

function* updateSurveys() {
	// TODO: SurveyTTL
	const { allIds } = yield select(getSurvey);

	// Fetch for all survey ids
	const surveyIds = yield call(fetchSurveyIds);

	if (Array.isArray(surveyIds) && Array.isArray(surveyIds) && surveyIds.length > allIds.length) {
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

function savedExists(scheduleIds, savedArray) {
	const existsArray = [];
	if (Array.isArray(savedArray)) {
		for (let i = 0; i < savedArray.length; ++i) {
			if (scheduleIds.includes(savedArray[i])) {
				existsArray.push(savedArray[i]);
			}
		}
	}
	return existsArray;
}

function prefetchSpecialEventsImages(specialEvents) {
	if (specialEvents['logo']) {
		Image.prefetch(specialEvents['logo']);
	}
	if (specialEvents['logo-sm']) {
		Image.prefetch(specialEvents['logo-sm']);
	}
	if (specialEvents['map']) {
		Image.prefetch(specialEvents['map']);
	}
}

function prefetchLinkImages(links) {
	if (Array.isArray(links)) {
		links.forEach((item) => {
			const imageUrl = item.icon;
			// Check if actually a url and not icon name
			if (imageUrl.indexOf('fontawesome:') !== 0) {
				Image.prefetch(imageUrl);
			}
		});
	}
}

function* dataSaga() {
	yield call(watchData);
}

export default dataSaga;
