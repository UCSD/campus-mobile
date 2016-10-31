// Converts from degrees to radians.
Math.radians = function (degrees) {
	return (degrees * Math.PI) / 180;
};

// Converts from radians to degrees.
Math.degrees = function (radians) {
	return (radians * 180) / Math.PI;
};

module.exports = {

	getDistance(lat1, long1, lat2, long2) {
		if (lat1 && long1 && lat2 && long2) {
			const Phi1 = Math.radians(lat1);
			const Phi2 = Math.radians(lat2);
			const DeltaLambda = Math.radians(long2 - long1);
			const EarthRadius = 6371000;	// Earth radius in meters

			const DistanceMeters = Math.acos( (Math.sin(Phi1) * Math.sin(Phi2)) + (Math.cos(Phi1) * Math.cos(Phi2) * Math.cos(DeltaLambda)) ) * EarthRadius;

			return Math.floor(DistanceMeters);
		}
		else {
			return null;
		}
	},

	getMinutesETA(secondsToArrival) {
		if (secondsToArrival < 1) {
			return ('Arrived');
		} else if (secondsToArrival < 60) {
			return ('<1 min');
		} else {
			let secondsToArrivalDec = secondsToArrival;
			let minsToArrival = 1;

			while (secondsToArrivalDec > 60) {
				secondsToArrivalDec -= 60;
				minsToArrival++;
			}

			if (minsToArrival === 1) {
				return ('1 min');
			} else {
				return (minsToArrival + ' mins');
			}
		}
	},

};
