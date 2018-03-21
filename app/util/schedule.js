/**
* A module containing class schedule helper functions
* @module schedule
*/
module.exports = {
	// Returns a modified courseItems object containing only finals.
	getFinals(courseItems) {
		const finalItems = {
			SA: [],
			SU: [],
			MO: [],
			TU: [],
			WE: [],
			TH: [],
			FR: []
		};

		Object.keys(courseItems).forEach((day) => {
			courseItems[day].forEach(function(item) {
				if (item.special_mtg_code == "FI") {
					finalItems[day].push(item);
				}
			});
		});

		return finalItems;
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
			SU: []
		};

		Object.keys(courseItems).forEach((day) => {
			courseItems[day].forEach(function(item) {
				if (item.special_mtg_code == "") {
					classItems[day].push(item);
				}
			});
		});

		return classItems;
	},

	dayOfWeekInterpreter(abbr) {
		fullString = '';
		switch (abbr) {
		case 'MO':
			fullString = 'Monday';
			break;
		case 'TU':
			fullString = 'Tuesday';
			break;
		case 'WE':
			fullString = 'Wednesday';
			break;
		case 'TH':
			fullString = 'Thursday';
			break;
		case 'FR':
			fullString = 'Friday';
			break;
		case 'SA':
			fullString = 'Saturday';
			break;
		case 'SU':
			fullString = 'Sunday';
			break;
		default:
			fullString = abbr;
		}
		return fullString;
	},

	// Returns a courseItems object containing lists of courseItem objects.
	// There is one list per day of the week and the courseItem objects are
	// sorted by their start times. This includes "FI" and "RE" meeting types.
	getData(data) {
		const courses = data.data;
		const enrolledCourses = [];
		const courseItems = {
			MO: [],
			TU: [],
			WE: [],
			TH: [],
			FR: [],
			SA: [],
			SU: []
		};

		// loop thru "data"
		// grab all enrolled classes bc academic history has dropped/waitlisted classes too...
		for (let i = 0; i < courses.length; ++i) {
			if (courses[i].enrollment_status === 'EN') {
				enrolledCourses.push(courses[i]);
			}
		}

		// grab all "section_data" where "special_mtg_code" === ""
		// put into days
		for (let j = 0; j < enrolledCourses.length; ++j) {
			const currCourse = enrolledCourses[j];
			const currSectionData = currCourse.section_data;
			for (let k = 0; k < currSectionData.length; ++k) {
				const currData = currSectionData[k];
				// if (currData.special_mtg_code === '') {
				// time format is HH:MM - HH:MM
				// split time string and get seconds
				const timeString = currData.time;
				const timeArr = timeString.split(' ');
				const startString = timeArr[0];
				const endString = timeArr[2];
				const startArr = startString.split(':'); // split it at the colons
				const endArr = endString.split(':'); // split it at the colons
				// minutes are worth 60 seconds. Hours are worth 60 minutes.
				const startSeconds = +startArr[0] * 60 * 60 + +startArr[1] * 60;
				const endSeconds = +endArr[0] * 60 * 60 + +endArr[1] * 60;

				const day = currData.days;

				const item = {
					building: currData.building,
					room: currData.room,
					instructor_name: currData.instructor_name,
					section: currData.section,
					subject_code: currCourse.subject_code,
					course_code: currCourse.course_code,
					course_title: currCourse.course_title,
					time_string: timeString,
					start_time: startSeconds,
					end_time: endSeconds,
					meeting_type: currData.meeting_type,
					special_mtg_code: currData.special_mtg_code,
					day_code: currData.days,
					grade_option: currCourse.grade_option
				};

				courseItems[day].push(item);
				// }
			}
		}

		// sort by "time"
		const courseItemsKeys = Object.keys(courseItems);
		for (let l = 0; l < courseItemsKeys.length; ++l) {
			const courseItem = courseItems[courseItemsKeys[l]];
			courseItem.sort(this.sortTime);
		}
		return courseItems;
	},

	sortTime(a, b) {
		return a.start_time - b.start_time;
	},

	setFinals(finalsList) {
		let nowTime = new Date().getDay();
		const upcomingFinals = {};

		const mapWeekdays = [
			'SA',
			'SU',
			'MO',
			'TU',
			'WE',
			'TH',
			'FR',
		];

		// translates the days from nowTime to match the days returned from getFinals
		nowTime = (nowTime + 1) % 7;

		// Pushes only upcoming finals to new object
		for (let i = nowTime; i < 7; i++) {
			if (finalsList[mapWeekdays[i]].length > 0) {
				upcomingFinals[mapWeekdays[i]] = finalsList[mapWeekdays[i]];
			}
		}

		return upcomingFinals;
	}
};
