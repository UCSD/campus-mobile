const shuttle_routes = require('../json/shuttle_routes_master_map.json');
const shuttle_stops = require('../json/shuttle_stops_master_map.json');
const shuttle_stops_no_routes = require('../json/shuttle_stops_master_map_no_routes.json');

const initialToggles = {};
Object.keys(shuttle_routes).forEach((key, index) => {
	initialToggles[key] = false;
});

const initialState = {
	toggles: initialToggles,
	routes: shuttle_routes,
	stops: shuttle_stops_no_routes,
	vehicles: {},
};

function shuttle(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
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
	case 'SET_VEHICLES':
		const veh = Object.assign({}, newState.vehicles);
		veh[action.route] = action.vehicles;
		newState.vehicles = veh;

		return newState;
	default:
		return state;
	}
}

module.exports = shuttle;
