const initialState = {
	toggles: null,
	routes: null,// shuttle_routes,
	stops: null,// shuttle_stops_no_routes,
	savedStops: [],
	vehicles: {},
	closestStop: null,
	lastUpdated: 0,
	lastScroll: 0
}

function shuttle(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_SHUTTLE_MASTER':
			newState.routes = action.routes
			newState.stops = action.stops
			newState.toggles = action.toggles
			newState.lastUpdated = action.nowTime
			return newState
		case 'TOGGLE_ROUTE':
			newState.toggles = action.newToggles
			newState.stops = action.newStops
			return newState
		case 'SET_VEHICLES': {
			const vehicles = {}
			vehicles[action.route] = action.vehicles
			newState.vehicles = vehicles
			return newState
		}
		case 'SET_CLOSEST_STOP':
			newState.closestStop = Object.assign({}, action.closestStop)
			return newState
		case 'SET_ARRIVALS': {
			newState.stops = action.stops
			return newState
		}
		case 'CHANGED_STOPS': {
			newState.savedStops = action.savedStops
			return newState
		}
		case 'SET_SHUTTLE_SCROLL': {
			newState.lastScroll = action.lastScroll
			return newState
		}
		default:
			return state
	}
}

module.exports = shuttle
