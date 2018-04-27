/**
 * Converts from degrees to radians
 * @param {number} degrees - The quantity in degrees
 * @return {number} The quantity, now in radians
 */
Math.radians = function (degrees) {
	return (degrees * Math.PI) / 180;
};

/**
 * Converts from radians to degrees
 * @param {number} radians - The quantity in radians
 * @return {number} The quantity, now in degrees
 */
Math.degrees = function (radians) {
	return (radians * 180) / Math.PI;
};

/**
 * A module containing map-related helper functions
 * @module util/map
 */
module.exports = {

	/**
	 * Gets the surface distance between two Earth coordinates in meters
	 * @function
	 * @param {number} lat1 The latitude of the first point
	 * @param {number} lon1 The longitude of the first point
	 * @param {number} lat2 The latitude of the second point
	 * @param {number} lon2 The longitude of the second point
	 * @return {number|null} Null if any of the inputs were null. Otherwise, the distance in meters (rounded down the nearest integer)
	 */
	getDistance(lat1, lon1, lat2, lon2) {
		if (lat1 && lon1 && lat2 && lon2) {
			const Phi1 = Math.radians(lat1);
			const Phi2 = Math.radians(lat2);
			const DeltaLambda = Math.radians(lon2 - lon1);
			const EarthRadius = 6371000;	// Earth radius in meters

			const DistanceMeters = Math.acos( (Math.sin(Phi1) * Math.sin(Phi2)) + (Math.cos(Phi1) * Math.cos(Phi2) * Math.cos(DeltaLambda)) ) * EarthRadius;

			return Math.floor(DistanceMeters);
		} else {
			return null;
		}
	},

	/**
	 * Gets the coordinates of the midpoint between two coordinates
	 * @function
	 * @param {number} lat1 The latitude of the first point
	 * @param {number} lon1 The longitude of the first point
	 * @param {number} lat2 The latitude of the second point
	 * @param {number} lon2 The longitude of the second point
	 * @returns {number[]} The midpoint coordinates stored in a 2-length array with the form {latitude, longitude}
	 */
	getMidpointCoords(lat1, lon1, lat2, lon2) {
		if (lat1 && lon1 && lat2 && lon2) {
			lat1 = Math.radians(lat1);
			lon1 = Math.radians(lon1);
			lat2 = Math.radians(lat2);
			lon2 = Math.radians(lon2);
			const bx = Math.cos(lat2) * Math.cos(lon2 - lon1);
			const by = Math.cos(lat2) * Math.sin(lon2 - lon1);
			const lat3 = Math.atan2(Math.sin(lat1) + Math.sin(lat2), Math.sqrt((Math.cos(lat1) + bx) * (Math.cos(lat1) + bx) + Math.pow(by, 2)));
			const lon3 = lon1 + Math.atan2(by, Math.cos(lat1) + bx);
			return [Math.round(Math.degrees(lat3), 5), Math.round(Math.degrees(lon3), 5)];
		} else {
			return null;
		}
	}

};
