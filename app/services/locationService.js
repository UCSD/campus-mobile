import Geolocation from '@react-native-community/geolocation'

const positionOptions = {
	enableHighAccuracy: false,
	timeout: 5000,
}

module.exports = {
	getPosition() {
		return new Promise((resolve, reject) => {
			Geolocation.getCurrentPosition(
				(position) => {
					resolve(position)
				},
				(error) => {
					reject(error)
				},
				positionOptions
			)
		})
	}
}
