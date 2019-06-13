import moment from 'moment'
/**
 * A module containing occuspace related helper functions
 * @module util/occuspace
 */
module.exports = {
	/**
	 * creates a map of strings to objects that holds all locations
	 * @param {[Object]]}
	 * @returns {{int,Object}}} map of occuspace locationNames to occuspaceObjects
	 */
	getLocationsMap(occuspaceData) {
		const map = {}
		if (occuspaceData) {
			// only add the selcted locations
			occuspaceData.forEach((obj) => {
				map[obj.locationName] = obj
			})
		}
		return map
	},
	/**
	 * creates an array of objects that holds only selected locations in order
	 * @param {[String:Object]}
	 * @param {[String]} array of selected locations in order
	 * @returns {[Object]} array of location objects in given order
	 */
	getSelectedLocations(occuspaceData, selectedLocations) {
		const locations = []
		if (occuspaceData) {
			// only add the selcted locations
			selectedLocations.forEach((location) => {
				locations.push(occuspaceData[location])
			})
		}
		return locations
	},
}
