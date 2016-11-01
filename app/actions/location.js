
import * as LocationService from '../services/locationService';
import logger from '../util/logger';

function updateLocation() {
	return (dispatch) => {
		LocationService.getPosition()
			.then((position) => {
				dispatch({
					type: 'SET_POSITION',
					position
				});
			})
			.catch(logger.error);
	};
}

function setPermission(permission) {
	return {
		type: 'SET_PERMISSION',
		permission
	};
}

module.exports = {
	updateLocation,
	setPermission
};
