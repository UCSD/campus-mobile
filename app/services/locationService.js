
const logger = require('../util/logger');

const positionOptions = {
	enableHighAccuracy: false,
	timeout: 5000,
};

export function getPosition() {
	return new Promise((resolve, reject) => {
		navigator.geolocation.getCurrentPosition(
			(position) => {
				resolve(position); },
			(error) => {
				//logger.log('getPosition Error: ' + JSON.stringify(error));
				reject(error);
			},
			positionOptions
		);
	});
}

export function getPermission() {
	return new Promise((resolve, reject) => {
	});
}
