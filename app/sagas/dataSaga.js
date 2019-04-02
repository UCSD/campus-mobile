
import { delay } from 'redux-saga'
import { put, call, select } from 'redux-saga/effects'
import { Image } from 'react-native'

import WeatherService from '../services/weatherService'
import SpecialEventsService from '../services/specialEventsService'
import LinksService from '../services/quicklinksService'
import EventService from '../services/eventService'
import NewsService from '../services/newsService'
import ParkingService from '../services/parkingService'
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
	PARKING_API_TTL
} from '../AppSettings'

const getWeather = state => (state.weather)
const getSurf = state => (state.surf)
const getSpecialEvents = state => (state.specialEvents)
const getLinks = state => (state.links)
const getEvents = state => (state.events)
const getNews = state => (state.news)
const getCards = state => (state.cards)
const getShuttle = state => (state.shuttle)
const getUserData = state => (state.user)
const getParkingData = state => (state.parking)

function* watchData() {
	while (true) {
		try {
			yield call(updateWeather)
			yield call(updateSurf)
			yield call(updateSpecialEvents)
			yield call(updateLinks)
			yield call(updateParking)
			yield call(updateEvents)
			yield call(updateNews)
			yield call(updateShuttleMaster)
			yield put({ type: 'UPDATE_DINING' })
			yield put({ type: 'UPDATE_SCHEDULE' })
			yield put({ type: 'SYNC_USER_PROFILE' })
		} catch (err) {
			console.log(err)
		}
		yield delay(DATA_SAGA_TTL)
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

function* updateParking() {
	const { lastUpdated, parkingData } = yield select(getParkingData),
		nowTime = new Date().getTime(),
		ttl = PARKING_API_TTL,
		timeDiff = nowTime - lastUpdated

	if (timeDiff > ttl) {
		// Fetch for new data
		const newParkingData = yield call(ParkingService.FetchParking)
		if (newParkingData) {
			newParkingData.sort(sortByOldParkingData(parkingData))
			yield put({ type: 'SET_PARKING_DATA', newParkingData })
		}
		// get previously selected lots from users synced profile
		const userData = yield select(getUserData)
		const prevSelectedParkingLots = userData.profile.selectedLots
		if (prevSelectedParkingLots) {
			yield put({ type: 'SYNC_PARKING_LOTS_DATA', prevSelectedParkingLots })
		}
	}
}

// comparator function to sort all the parking lots in the same order as a parking data structure which is passed in
function sortByOldParkingData(parkingData) {
	console.log(parkingData)
	return function (a, b) {
		return parkingData.findIndex(x => x.LocationName === a.LocationName) - parkingData.findIndex(x => x.LocationName === b.LocationName)
	}
}


// comparator function to sort all the parking lots in alphanumeric order based on the LocationName
function compare(e1, e2) {
	if (e1.LocationName < e2.LocationName) {
		return -1
	}
	if (e1.LocationName > e2.LocationName) {
		return 1
	}
	return 0
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
