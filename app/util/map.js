// Converts from degrees to radians
Math.radians = function (degrees) {
	return (degrees * Math.PI) / 180;
};

// Converts from radians to degrees
Math.degrees = function (radians) {
	return (radians * 180) / Math.PI;
};

module.exports = {

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

	getMidpointCoords: function(lat1, lon1, lat2, lon2) {
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