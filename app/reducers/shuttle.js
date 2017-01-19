const shuttle_routes = require('../json/shuttle_routes_master_map.json');
const shuttle_stops = require('../json/shuttle_stops_master_map.json');

const initialToggles = {};
Object.keys(shuttle_routes).map((key, index) => {
	initialToggles[key] = true;
	return null;
});

const initialState = {
	toggles: initialToggles,
	routes: shuttle_routes,
	stops: shuttle_stops
};

function shuttle(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'TOGGLE_ROUTE':
		newState.toggles[action.route] = !state.toggles[action.route];

		if (newState.toggles[action.route] === false) {
			// Remove route from every stop
			Object.keys(newState.routes[action.route].stops).map((key2, index2) => {
				if (newState.stops[key2]) {
					delete newState.stops[key2].routes[action.route];
				}
				return null;
			});
		} else {
			// Add route to every stop
			Object.keys(newState.routes[action.route].stops).map((key2, index2) => {
				if (newState.stops[key2]) {
					newState.stops[key2].routes[action.route] = newState.routes[action.route];
				}
				return null;
			});
		}
		return newState;
	default:
		return state;
	}
}

module.exports = shuttle;
