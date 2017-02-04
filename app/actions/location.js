import * as LocationService from '../services/locationService';
import logger from '../util/logger';
import { updateClosestStop } from './shuttle';

function updateLocation() {
	return (dispatch) => {
		LocationService.getPosition()
			.then((position) => {
				dispatch({
					type: 'SET_POSITION',
					position
				});
				dispatch(updateClosestStop(position));
			})
			.catch((error) => {
				// ignore timeout error
				if (error.code === 3) return;

				logger.error(error);
			});
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
