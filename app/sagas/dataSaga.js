import { delay } from 'redux-saga'
import { put, call, select } from 'redux-saga/effects'
import { Image } from 'react-native'

import WeatherService from '../services/weatherService'
import ScheduleService from '../services/scheduleService'
import SpecialEventsService from '../services/specialEventsService'
import LinksService from '../services/quicklinksService'
import EventService from '../services/eventService'
import NewsService from '../services/newsService'
import schedule from '../util/schedule'
import { fetchMasterStopsNoRoutes, fetchMasterRoutes } from '../services/shuttleService'
import {
	WEATHER_API_TTL,
	SURF_API_TTL,
	SPECIAL_EVENTS_TTL,
	QUICKLINKS_API_TTL,
	EVENTS_API_TTL,
	NEWS_API_TTL,
	DATA_SAGA_TTL,
	SHUTTLE_MASTER_TTL,
	SCHEDULE_TTL,
} from '../AppSettings'

const getWeather = state => (state.weather)
const getSurf = state => (state.surf)
const getSpecialEvents = state => (state.specialEvents)
const getLinks = state => (state.links)
const getEvents = state => (state.events)
const getNews = state => (state.news)
const getCards = state => (state.cards)
const getShuttle = state => (state.shuttle)
const getSchedule = state => (state.schedule)
const getUserData = state => (state.user)

// AUTH
const auth = require('../util/auth')

function* watchData() {
	while (true) {
		try {
			yield call(updateWeather)
			yield call(updateSurf)
			yield call(updateSpecialEvents)
			yield call(updateLinks)
			yield call(updateEvents)
			yield call(updateNews)
			yield call(updateShuttleMaster)
			yield put({ type: 'UPDATE_DINING' })
			yield call(updateSchedule)
		} catch (err) {
			console.log(err)
		}
		yield delay(DATA_SAGA_TTL)
	}
}

function* updateSchedule() {
	const { lastUpdated, data } = yield select(getSchedule)
	const { isLoggedIn, profile } = yield select(getUserData)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const scheduleTTL = SCHEDULE_TTL

	if (!isLoggedIn ||
			!profile.classifications.student ||
			(timeDiff < scheduleTTL && data)) {
		// Do nothing, no need to fetch new data
	} else {
		try {
			const term = yield call(ScheduleService.FetchTerm)
			if (term) {
				yield put({ type: 'SET_SCHEDULE_TERM', term })
			}

			const scheduleData = yield call(ScheduleService.FetchSchedule, term.code)
			if (scheduleData) {
				yield put({ type: 'SET_SCHEDULE', schedule: scheduleData })
			}

			// check for finals
			const parsedScheduleData = schedule.getData(scheduleData)
			const finalsData = schedule.getFinals(parsedScheduleData)
			const finalsArray = []
			Object.keys(finalsData).forEach((day) => {
				if (finalsData[day].length > 0) {
					finalsArray.push({
						day,
						data: finalsData[day]
					})
				}
			})
			if (finalsArray.length > 0) {
				// check if finals are active
				const finalsActive = yield call(ScheduleService.FetchFinals)
				if (finalsActive) {
					yield put({ type: 'SHOW_CARD', id: 'finals' })
				} else {
					yield put({ type: 'HIDE_CARD', id: 'finals' })
				}
			}
		} catch (error) {
			console.log(error)
		}
	}
}

function* updateShuttleMaster() {
	const { lastUpdated, routes, stops } = yield select(getShuttle)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const shuttleTTL = SHUTTLE_MASTER_TTL

	if ((timeDiff < shuttleTTL) && (routes !== null) && (stops !== null)) {
		// Do nothing, don't need to update
	} else {
		// Fetch for new data
		const stopsData = yield call(fetchMasterStopsNoRoutes)
		const routesData = yield call(fetchMasterRoutes)

		// Set toggles
		const initialToggles = {}
		Object.keys(routesData).forEach((key, index) => {
			initialToggles[key] = false
		})

		yield put({
			type: 'SET_SHUTTLE_MASTER',
			stops: stopsData,
			routes: routesData,
			toggles: initialToggles,
			nowTime
		})
	}
}

function* updateWeather() {
	const { lastUpdated, data } = yield select(getWeather)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const weatherTTL = WEATHER_API_TTL

	if (timeDiff < weatherTTL && data) {
		// Do nothing, no need to fetch new data
	} else {
		const weather = yield call(WeatherService.FetchWeather)
		if (weather) {
			yield put({ type: 'SET_WEATHER', weather })
		}
	}
}

function* updateSurf() {
	const { lastUpdated, data } = yield select(getSurf)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const ttl = SURF_API_TTL

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		const surf = yield call(WeatherService.FetchSurf)
		if (surf) {
			yield put({ type: 'SET_SURF', surf })
		}
	}
}

function* updateSpecialEvents() {
	const { lastUpdated, saved } = yield select(getSpecialEvents)
	const { cards } = yield select(getCards)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const ttl = SPECIAL_EVENTS_TTL

	if (timeDiff > ttl && Array.isArray(saved)) {
		const specialEvents = yield call(SpecialEventsService.FetchSpecialEvents)

		if (specialEvents &&
			specialEvents['start-time'] <= nowTime &&
			specialEvents['end-time'] >= nowTime) {
			// Inside active specialEvents window
			prefetchSpecialEventsImages(specialEvents)
			if (cards.specialEvents.autoActivated === false) {
				// Initialize SpecialEvents for first time use
				// wipe saved data
				yield put({ type: 'CHANGED_SPECIAL_EVENTS_SAVED', saved: [] })
				yield put({ type: 'CHANGED_SPECIAL_EVENTS_LABELS', labels: [] })
				yield put({ type: 'SET_SPECIAL_EVENTS', specialEvents })
				// set active and autoActivated to true
				yield put({ type: 'UPDATE_CARD_STATE', id: 'specialEvents', state: true })
				yield put({ type: 'UPDATE_AUTOACTIVATED_STATE', id: 'specialEvents', state: true })
				yield put({ type: 'SHOW_CARD', id: 'specialEvents' })
			} else if (cards.specialEvents.active) {
				// remove any saved items that no longer exist
				if (saved.length > 0) {
					const stillsExists = yield call(savedExists, specialEvents.uids, saved)
					yield put({ type: 'CHANGED_SPECIAL_EVENTS_SAVED', saved: stillsExists })
					yield put({ type: 'CHANGED_SPECIAL_EVENTS_LABELS', labels: [] })
				}
				yield put({ type: 'SET_SPECIAL_EVENTS', specialEvents })
			}
		} else {
			// Outside active specialEvents window
			// Set Special Events to null
			yield put({ type: 'SET_SPECIAL_EVENTS', specialEvents: null })

			// wipe saved data
			yield put({ type: 'CHANGED_SPECIAL_EVENTS_SAVED', saved: [] })
			yield put({ type: 'CHANGED_SPECIAL_EVENTS_LABELS', labels: [] })

			// set active and autoactivated to false
			yield put({ type: 'UPDATE_CARD_STATE', id: 'specialEvents', state: false })
			yield put({ type: 'UPDATE_AUTOACTIVATED_STATE', id: 'specialEvents', state: false })
			yield put({ type: 'HIDE_CARD', id: 'specialEvents' })
		}
	}
}

function* updateLinks() {
	const { lastUpdated, data } = yield select(getLinks)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const ttl = QUICKLINKS_API_TTL

	if ((timeDiff < ttl) && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const links = yield call(LinksService.FetchQuicklinks)

		if (links) {
			yield put({ type: 'SET_LINKS', links })
			prefetchLinkImages(links)
		}
	}
}

function* updateEvents() {
	const { lastUpdated, data } = yield select(getEvents)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const ttl = EVENTS_API_TTL

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const events = yield call(EventService.FetchEvents)
		yield put({ type: 'SET_EVENTS', events })
	}
}

function* updateNews() {
	const { lastUpdated, data } = yield select(getNews)
	const nowTime = new Date().getTime()
	const timeDiff = nowTime - lastUpdated
	const ttl = NEWS_API_TTL

	if (timeDiff < ttl && data) {
		// Do nothing, no need to fetch new data
	} else {
		// Fetch for new data
		const news = yield call(NewsService.FetchNews)
		yield put({ type: 'SET_NEWS', news })
	}
}

function savedExists(scheduleIds, savedArray) {
	const existsArray = []
	if (Array.isArray(savedArray)) {
		for (let i = 0; i < savedArray.length; ++i) {
			if (scheduleIds.includes(savedArray[i])) {
				existsArray.push(savedArray[i])
			}
		}
	}
	return existsArray
}

function prefetchSpecialEventsImages(specialEvents) {
	if (specialEvents.logo) {
		Image.prefetch(specialEvents.logo)
	}
	if (specialEvents['logo-sm']) {
		Image.prefetch(specialEvents['logo-sm'])
	}
	if (specialEvents.map) {
		Image.prefetch(specialEvents.map)
	}
}

function prefetchLinkImages(links) {
	if (Array.isArray(links)) {
		links.forEach((item) => {
			const imageUrl = item.icon
			// Check if actually a url and not icon name
			if (imageUrl.indexOf('fontawesome:') !== 0) {
				Image.prefetch(imageUrl)
			}
		})
	}
}

function* dataSaga() {
	yield call(watchData)
}

export default dataSaga
