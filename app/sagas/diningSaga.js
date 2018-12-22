import { put, takeLatest, call, select, race } from 'redux-saga/effects'
import { delay } from 'redux-saga'
import logger from '../util/logger'
import DiningService from '../services/diningService'
import { DINING_API_TTL, DINING_MENU_API_TTL, HTTP_REQUEST_TTL } from '../AppSettings'
import { timeDiff, /* convertMetersToMiles, getDistanceMilesStr, dynamicSort */ } from '../util/general'
// import { getDistance } from '../util/map'

const getDining = state => (state.dining)

export function* updateDining() {
	const { lastUpdated } = yield select(getDining)
	if (timeDiff(lastUpdated) > DINING_API_TTL) {
		const dining = yield call(DiningService.FetchDining)
		if (dining) {
			yield put({ type: 'SET_DINING', data: dining })
		}
	}
}

function* getDiningMenu(action) {
	const { menus, lookup } = yield select(getDining)
	const { menuId } = action

	const nowTime = new Date().getTime()
	const diningMenuTTL = DINING_MENU_API_TTL

	const menuArrayPosition = lookup[menuId]
	if (menus[menuArrayPosition]) {
		const menuTimeDiff = nowTime - menus[menuArrayPosition].lastUpdated
		if (menuTimeDiff > diningMenuTTL || !menus[menuArrayPosition] || !menuTimeDiff) {
			const currentMenu = yield call(fetchDiningMenu, menuId)
			yield put({ type: 'SET_DINING_MENU', data: currentMenu, id: menuArrayPosition })
		}
	} else {
		const currentMenu = yield call(fetchDiningMenu, menuId)
		yield put({ type: 'SET_DINING_MENU', data: currentMenu, id: menuArrayPosition })
	}
}

function* fetchDiningMenu(id) {
	yield put({ type: 'GET_DINING_MENU_REQUEST' })

	try {
		const { response, timeout } = yield race({
			response: call(DiningService.FetchDiningMenu, id),
			timeout: call(delay, HTTP_REQUEST_TTL)
		})

		if (timeout) {
			const e = new Error('Request timed out.')
			throw e
		} else if (!response || !response.menuitems) {
			// const e = new Error('Invalid server response.')
			// throw e
			yield put({ type: 'GET_DINING_MENU_SUCCESS' })
			return null
		} else {
			yield put({ type: 'GET_DINING_MENU_SUCCESS' })
			return response
		}
	} catch (error) {
		logger.log(error)
		yield put({ type: 'GET_DINING_MENU_FAILURE', error })
	}
}

/*
function _sortDining(diningData) {
	// Sort dining locations by name
	return new Promise((resolve, reject) => {
		if (Array.isArray(diningData)) {
			const sortedDiningData = diningData.slice()
			sortedDiningData.sort(dynamicSort('name'))
			resolve(diningData)
		} else {
			reject(new Error('Error _sortDining, diningData is not an array(' + diningData + ')'))
		}
	})
}

function _setDiningDistance(position, diningData) {
	// Calc distance from dining locations
	return new Promise((resolve, reject) => {
		if (Array.isArray(diningData)) {
			resolve(diningData.map((eatery) => {
				let distance
				if (eatery.coords) {
					distance = getDistance(position.coords.latitude, position.coords.longitude, eatery.coords.lat, eatery.coords.lon)
					if (distance) {
						eatery = {
							...eatery,
							distance
						}
					}
				} else {
					eatery = {
						...eatery,
						distance: 100000000
					}
				}

				const milesDistance = convertMetersToMiles(distance)
				eatery = {
					...eatery,
					distanceMiles: milesDistance,
					distanceMilesStr: getDistanceMilesStr(milesDistance)
				}

				return eatery
			}))
		} else {
			reject(new Error('Error _setDiningDistance'))
		}
	})
}
*/

function* diningSaga() {
	yield takeLatest('GET_DINING_MENU', getDiningMenu)
}

export default diningSaga
