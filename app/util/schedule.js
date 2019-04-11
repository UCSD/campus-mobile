import moment from 'moment'

/**
* A module containing class schedule helper functions
* @module schedule
*/
module.exports = {
	// Returns a modified courseItems object containing only finals.
	getFinals(courseItems) {
		const finalItems = {
			MO: [],
			TU: [],
			WE: [],
			TH: [],
			FR: [],
			SA: [],
			SU: [],
			OTHER: []
		}

		Object.keys(courseItems).forEach((day) => {
			courseItems[day].forEach((item) => {
				if (item.special_mtg_code === 'FI') {
					finalItems[day].push(item)
				}
			})
		})

		return finalItems
	},

	// Returns a modified courseItems object containing only classes (includes discussions).
	getClasses(courseItems) {
		const classItems = {
			MO: [],
			TU: [],
			WE: [],
			TH: [],
			FR: [],
			SA: [],
			SU: [],
			OTHER: []
		}

		Object.keys(courseItems).forEach((day) => {
			courseItems[day].forEach((item) => {
				if (!item.special_mtg_code) {
					classItems[day].push(item)
				}
			})
		})

		return classItems
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

	// Returns a courseItems object containing lists of courseItem objects.
	// There is one list per day of the week and the courseItem objects are
	// sorted by their start times. This includes "FI" and "RE" meeting types.
	getData(data) {
		try {
			const courses = data.data
			const enrolledCourses = []
			const courseItems = {
				MO: [],
				TU: [],
				WE: [],
				TH: [],
				FR: [],
				SA: [],
				SU: [],
				OTHER: []
			}

			// loop thru "data"
			// grab all enrolled classes bc academic history has dropped/waitlisted classes too...
			if (Array.isArray(courses)) {
				for (let i = 0; i < courses.length; ++i) {
					if (courses[i].enrollment_status === 'EN') {
						enrolledCourses.push(courses[i])
					}
				}
			}

			// grab all "section_data" where "special_mtg_code" === ""
			// put into days
			for (let j = 0; j < enrolledCourses.length; ++j) {
				const currCourse = enrolledCourses[j]
				const currSectionData = currCourse.section_data
				for (let k = 0; k < currSectionData.length; ++k) {
					const currData = currSectionData[k]

					if (currData.special_mtg_code === '') {
						// time format is HH:MM - HH:MM
						// split time string and get seconds
						const timeString = currData.time
						let startSeconds,
							endSeconds,
							formattedTimeString,
							formattedStartString

						if (timeString) {
							const timeArr = timeString.split(' ')
							const startString = timeArr[0]
							const endString = timeArr[2]
							const startArr = startString.split(':') // split it at the colons
							const endArr = endString.split(':') // split it at the colons
							// minutes are worth 60 seconds. Hours are worth 60 minutes.
							startSeconds = (+startArr[0] * 60 * 60) + (+startArr[1] * 60)
							endSeconds = (+endArr[0] * 60 * 60) + (+endArr[1] * 60)
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

						let day = 'OTHER'
						if (currData.days) {
							day = currData.days
						}

						const item = {
							building: currData.building,
							room: currData.room,
							instructor_name: currData.instructor_name,
							section: currData.section,
							subject_code: currCourse.subject_code,
							course_code: currCourse.course_code,
							course_title: currCourse.course_title,
							time_string: formattedTimeString,
							start_string: formattedStartString,
							start_time: startSeconds,
							end_time: endSeconds,
							meeting_type: currData.meeting_type,
							special_mtg_code: currData.special_mtg_code,
							day_code: currData.days,
							grade_option: currCourse.grade_option
						}

						courseItems[day].push(item)
					}
				}
			}

			// sort by "time"
			const courseItemsKeys = Object.keys(courseItems)
			for (let l = 0; l < courseItemsKeys.length; ++l) {
				const courseItem = courseItems[courseItemsKeys[l]]
				courseItem.sort(this.sortTime)
			}

			return courseItems
		} catch (err) {
			console.log(err)
			return []
		}
	},

	sortTime(a, b) {
		return a.start_time - b.start_time
	},
}
