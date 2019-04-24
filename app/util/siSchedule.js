import moment from 'moment'
/**
 * A module containing SI-Session related helper functions
 * @module util/SISessions
 */
module.exports = {
	hasSessions(SIData, instructor_name, course_title) {
		if (SIData) {
			// check if the class has SIsessions
			if (SIData[course_title]) {
				// check if your professor has SIsessions
				if (SIData[course_title][instructor_name]) {
					return true
				}
			}
		}
		return false
	},
	reorderWeekDays(scheduleObj) {
		const scheduleArray = []
		if (scheduleObj.Monday) scheduleArray.push(scheduleObj.Monday)
		if (scheduleObj.Tuesday) scheduleArray.push(scheduleObj.Tuesday)
		if (scheduleObj.Wednesday) scheduleArray.push(scheduleObj.Wednesday)
		if (scheduleObj.Thursday) scheduleArray.push(scheduleObj.Thursday)
		if (scheduleObj.Friday) scheduleArray.push(scheduleObj.Friday)
		if (scheduleObj.Saturday) scheduleArray.push(scheduleObj.Saturday)
		if (scheduleObj.Sunday) scheduleArray.push(scheduleObj.Sunday)
		if (scheduleObj.Other) scheduleArray.push(scheduleObj.Other)
		return scheduleArray
	},
	convertTime(timeString) {
		let formattedTimeString,
			formattedStartString

		if (timeString) {
			const timeArr = timeString.split(' ')
			const startString = timeArr[0]
			const endString = timeArr[2]
			const startMoment = moment(startString, 'HH:mm')
			const endMoment = moment(endString, 'HH:mm')
			const startAm = Boolean(startMoment.format('a') === 'am')
			const endAm = Boolean(endMoment.format('a') === 'am')
			formattedStartString = moment(startString, 'HH:mm').format('h:mm') +
				(startAm ? (' a.m.') : (' p.m.'))
			const formattedEndString = moment(endString, 'HH:mm').format('h:mm') +
				(endAm ? (' a.m.') : (' p.m.'))
			formattedTimeString = formattedStartString +
				' – ' + formattedEndString
		}
		return formattedTimeString
	},
	getSessionsForSchedule(SISessionsDict, classSchedule) {
		const arrToReturn = []
		for (let i = 0;  i < classSchedule.length; i++) {
			const curr = classSchedule[i].split('___')
			const instructor = curr[1]
			const class_name = curr[0]

			// console.log(class_name + ' has si at:')

			if (!SISessionsDict[class_name]) {
				// console.log(' *** No si sessions set')
			} else {
				const class_dict = SISessionsDict[class_name]
				if (!class_dict[instructor]) {
					// console.log(' *** A si session exists for this class, but not this instructor')
				} else {
					const tutoring_data = class_dict[instructor]
					Object.keys(tutoring_data).forEach((leader) => {
						const session = tutoring_data[leader]
						// console.log(' *** A si session exists for this class, and this instructor')
						for (let j = 0; j < session.length; j++) {
							const currTutorSession = session[j]
							const course = class_name.split('_')
							currTutorSession.course = course[0] + ' ' + course[1]
							arrToReturn.push(tutoring_data[j])
						}
					})
				}
			}
		}
		return arrToReturn
	},
	dayOfWeekInterpreter(abbr) {
		let fullString = ''
		switch (abbr) {
			case 'MO':
				fullString = 'Monday'
				break
			case 'TU':
				fullString = 'Tuesday'
				break
			case 'WE':
				fullString = 'Wednesday'
				break
			case 'TH':
				fullString = 'Thursday'
				break
			case 'FR':
				fullString = 'Friday'
				break
			case 'SA':
				fullString = 'Saturday'
				break
			case 'SU':
				fullString = 'Sunday'
				break
			default:
				fullString = 'Other'
		}
		return fullString
	},

	populateArr(jsonData) {
		const classSchedule = []
		Object.keys(jsonData.data).forEach((key) => {
			if (jsonData.data[key].enrollment_status === 'EN') {
				if (!(jsonData.data[key].section_data === undefined || jsonData.data[key].section_data.length === 0)) {
					const instructor = jsonData.data[key].section_data[0].instructor_name
					if (Object.prototype.hasOwnProperty.call(jsonData.data, key)) {
						classSchedule.push(jsonData.data[key].subject_code + '_' + jsonData.data[key].course_code + '___' + instructor)
					}
				}
			}
		})
		return classSchedule
	},
}
