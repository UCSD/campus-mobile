/**
 * A module containing occuspace related helper functions
 * @module util/occuspace
 */
module.exports = {
	/**
	 * Gets the slected occuspace locations from the data passed in
	 * @param {[Object]} occuslaceData The array of all occuspace locations
	 * @param {[String]} selectedLocations The array strings that correspond to all slected occuspace locations
	 * @returns {[Object]]} An array of of ojects that has only the selcted occupace locations
	 */
	getSelectedOccusapceLocations(occuspaceData, selectedLocations) {
		const arrayToReturn = []
		if (occuspaceData) {
			occuspaceData.forEach((locationObj) => {
				if (selectedLocations.includes(locationObj.locationName)) {
					arrayToReturn.push(locationObj)
				}
			})
		}
		return arrayToReturn
	},
}
