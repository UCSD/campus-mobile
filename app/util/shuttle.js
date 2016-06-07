'use strict';

// Converts from degrees to radians.
Math.radians = function(degrees) {
	return degrees * Math.PI / 180;
};

// Converts from radians to degrees.
Math.degrees = function(radians) {
	return radians * 180 / Math.PI;
};

module.exports = {

	convertMetersToFeetOrMiles: function(meters) {
		// Convert meters to feet -- if over 530 feet (>= .1 miles) convert to miles
		var distanceFeet = Math.round(meters * 3.2808);
		
		if (distanceFeet >= 530) {
			var distanceMiles = distanceFeet * 0.000189394;
			return (distanceMiles.toFixed(1) + " miles");
		} else {
			return (distanceFeet + " feet");
		}
	},

	getDistance: function(lat1, long1, lat2, long2) {

		if (lat1 && long1 && lat2 && long2) {

			var Phi1 = Math.radians(lat1);
			var Phi2 = Math.radians(lat2);
			var DeltaLambda = Math.radians(long2-long1);
			var EarthRadius = 6371000;	// Earth radius in meters

			var DistanceMeters = Math.acos( Math.sin(Phi1) * Math.sin(Phi2) + Math.cos(Phi1) * Math.cos(Phi2) * Math.cos(DeltaLambda) ) * EarthRadius;

			return Math.floor(DistanceMeters);

		} else {
			return null;
		}
	},

	getMinutesETA: function(secondsToArrival) {
		
		if (secondsToArrival < 1) {
			return ('Arrived');
		} else if (secondsToArrival < 60) {
			return ('<1 min');
		} else {
			var secondsToArrivalDec = secondsToArrival;
			var minsToArrival = 1;

			while (secondsToArrivalDec > 60) {
				secondsToArrivalDec -= 60;
				minsToArrival++;
			}

			if (minsToArrival == 1) {
				return ('1 min');
			} else {
				return (minsToArrival + ' mins');
			}
		}
	},
	
};