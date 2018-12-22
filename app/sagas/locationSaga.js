import { delay } from 'redux-saga'
import { put, call, select } from 'redux-saga/effects'
import Permissions from 'react-native-permissions'

import * as LocationService from '../services/locationService'
import { getDistance } from '../util/map'
import AppSettings from '../AppSettings'

const getLocation = state => (state.location)
const getShuttle = state => (state.shuttle)

function* watchLocation() {
	while (true) {
		try {
			const location = yield select(getLocation)

			if (location.permission === 'authorized' && location.position && location.position.coords) {
				const position = yield call(LocationService.getPosition)
				yield put({ type: 'SET_POSITION', position })
				const closestStop = yield call(getClosestStop, position)
				yield put({ type: 'SET_CLOSEST_STOP', closestStop })
			} else {
				const perm = yield call(getPermission, 'location')
				yield put({ type: 'SET_PERMISSION', permission: perm })
			}
		} catch (err) {
			console.log('Error: watchLocation: ' + err)
		}
		yield delay(AppSettings.LOCATION_TTL)
	}
}

function getPermission(type) {
	return Permissions.request(type)
}

function* getClosestStop(location) {
	const shuttle = yield select(getShuttle)
	const { stops } = shuttle
	const currClosestStop = shuttle.closestStop

	let closestDist = 1000000000
	let closestStop
	let closestSavedIndex = 0

	if (currClosestStop && currClosestStop.savedIndex) {
		closestSavedIndex = currClosestStop.savedIndex
	}

	Object.keys(stops).forEach((stopID, index) => {
		const stop = stops[stopID]
		const distanceFromStop = getDistance(location.coords.latitude, location.coords.longitude, stop.lat, stop.lon)

		if (distanceFromStop < closestDist) {
			closestStop = Object.assign({}, stop)
			closestDist = distanceFromStop
		}
	})
	closestStop.closest = true
	closestStop.savedIndex = closestSavedIndex

	return closestStop
}

function* locationSaga() {
	yield call(watchLocation)
}

export default locationSaga
