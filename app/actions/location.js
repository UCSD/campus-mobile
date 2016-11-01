
import { LocationService } from '../services/locationService';

function setLocation(location) {
	return {
		type: 'SET_LOCATION',
		location
	};
}

function requestPermission() {
}

module.exports = {
	setLocation,
	requestPermission
};
