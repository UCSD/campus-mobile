const initialState = {
	toggles: null,
	routes: null,// shuttle_routes,
	stops: null,// shuttle_stops_no_routes,
	vehicles: {},
	closestStop: null,
	lastUpdated: new Date().getTime(),
};

function shuttle(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_SHUTTLE_MASTER':
		newState.routes = action.routes;
		newState.stops = action.stops;
		newState.toggles = action.toggles;
		newState.lastUpdated = action.nowTime;

		return newState;
	case 'TOGGLE_ROUTE':
		newState.toggles[action.route] = !state.toggles[action.route];

		if (newState.toggles[action.route] === false) {
			// Remove route from every stop
			Object.keys(newState.routes[action.route].stops).forEach((key2, index2) => {
				if (newState.stops[key2]) {
					delete newState.stops[key2].routes[action.route];
					delete newState.vehicles[action.route];
				}
			});
		} else {
			// Add route to every stop
			Object.keys(newState.routes[action.route].stops).forEach((key2, index2) => {
				if (newState.stops[key2]) {
					newState.stops[key2].routes[action.route] = newState.routes[action.route];
				}
			});
		}

		return newState;
	case 'SET_VEHICLES': {
		const veh = Object.assign({}, newState.vehicles);
		veh[action.route] = action.vehicles;
		newState.vehicles = veh;

		return newState;
	}
	case 'SET_CLOSEST_STOP':
		newState.closestStop = Object.assign({}, action.closestStop);
		return newState;
	case 'SET_ARRIVALS': {
		//const stops = Object.assign({}, newState.stops);
		//stops[action.stop].arrivals = action.arrivalData;
		newState.stops = Object.assign({}, action.stops);

		return newState;
	}
	default:
		return state;
	}
}

module.exports = shuttle;
