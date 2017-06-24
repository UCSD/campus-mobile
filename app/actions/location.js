import * as LocationService from '../services/locationService';
import logger from '../util/logger';
import { updateClosestStop } from './shuttle';
import { updateDining } from './dining';

function updateLocation() {
	return (dispatch) => {
		LocationService.getPosition()
			.then((position) => {
				dispatch({
					type: 'SET_POSITION',
					position
				});
				dispatch(updateClosestStop(position));
				dispatch(updateDining(position));
			})
			.catch((error) => {
				// ignore timeout error, but still update dining
				if (error.code === 3) {
					dispatch(updateDining());
					return;
				}
				logger.log('Error fetching location: ' + error);
				return null;
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
