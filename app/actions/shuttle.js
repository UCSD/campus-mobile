import logger from '../util/logger';

function toggleRoute(route) {
	return {
		type: 'TOGGLE_ROUTE',
		route
	};
}

module.exports = {
	toggleRoute,
};
