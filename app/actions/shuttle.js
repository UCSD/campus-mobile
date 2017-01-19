import logger from '../util/logger';

function toggleRoute(route) {
	return {
		type: 'TOGGLE_ROUTE',
		route
	};
}

function fetchRoute(route) {
	return {
		type: 'FETCH_ROUTE',
		route
	};
}

function fetchStop(stop) {
	return {
		type: 'FETCH_STOP',
		stop
	};
}

module.exports = {
	toggleRoute,
	fetchRoute,
	fetchStop
};
