
/**
 * A module containing tutor-related helper functions
 * @module util/tutorSessions
 */
module.exports = {
	getSessions(tutoringData, classData) {
		const dict = this.populateDict(tutoringData)
		const arr =  this.populateArr(classData)

		// Add return before getTutorHours
		return this.getTutorHours(dict, arr)
	},

	// Call this from your tutoring session JSON
	populateDict(str_json) {
		const dict = []
		Object.keys(str_json.data).forEach((key) => {
			dict[key.toString()] = str_json.data[key]
		})
		return dict
	},

	// Logic to determine class / tutoring overlapping
	// TODO: change console.log to object building to return
	getTutorHours(tutorDict, arr) {
		const arrToReturn = []

		for (let i = 0;  i < arr.length; i++) {
			const curr = arr[i].split('___')
			const instructor = curr[1]
			const class_name = curr[0]

			console.log(class_name + ' has tutoring at:')

			if (!tutorDict[class_name]) {
				console.log(' *** No tutoring sessions set')
			} else {
				const class_dict = tutorDict[class_name]
				if (!class_dict[instructor]) {
					console.log(' *** A tutoring session exists for this class, but not this instructor')
				} else {
					const tutoring_data = class_dict[instructor]
					console.log(' *** A tutoring session exists for this class, and this instructor')
					for (let j = 0; j < tutoring_data.length; j++) {
						const currTutorSession = tutoring_data[j]
						const course = class_name.split('_')
						currTutorSession.course = course[0] + ' ' + course[1]
						arrToReturn.push(tutoring_data[j])
					}
				}
			}
		}
		return arrToReturn
	},

	populateArr(jsonData) {
		const arr = []
		Object.keys(jsonData.data).forEach((key) => {
			if (jsonData.data[key].enrollment_status === 'EN') {
				if (!(jsonData.data[key].section_data === undefined || jsonData.data[key].section_data.length === 0)) {
					const instructor = jsonData.data[key].section_data[0].instructor_name
					if (Object.prototype.hasOwnProperty.call(jsonData.data, key)) {
						arr.push(jsonData.data[key].subject_code + '_' + jsonData.data[key].course_code + '___' + instructor)
					}
				}
			}
		})
		return arr
	},
}
