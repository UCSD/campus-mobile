const data = {
	"metadata": {},
	"data": [
		{
			"term_code": "FA15",
			"subject_code": "CHIN",
			"course_code": "100AN",
			"units": 4,
			"course_level": "UD",
			"grade_option": "L",
			"course_title": "Third Yr Chinese/Non-Native I",
			"enrollment_status": "DR",
			"repeat_code": "N",
			"section_data": [
				{
					"section": "843632",
					"meeting_type": "Lecture",
					"time": "12:30 - 13:50",
					"days": "Tuesday",
					"building": "SEQUO",
					"room": "147",
					"instructor_name": "Wang, Xiao",
					"special_mtg_code": ""
				},
				{
					"section": "843632",
					"meeting_type": "Lecture",
					"time": "12:30 - 13:50",
					"days": "Thursday",
					"building": "SEQUO",
					"room": "147",
					"instructor_name": "Wang, Xiao",
					"special_mtg_code": ""
				},
				{
					"section": "843632",
					"meeting_type": "Lecture",
					"time": "11:30 - 14:29",
					"days": "Friday",
					"building": "SEQUO",
					"room": "147",
					"instructor_name": "Wang, Xiao",
					"special_mtg_code": "FI"
				}
			]
		},
		{
			"term_code": "FA15",
			"subject_code": "CSE",
			"course_code": "120",
			"units": 4,
			"course_level": "UD",
			"grade_option": "L",
			"course_title": "Princ/Computer Operating Systm",
			"enrollment_status": "EN",
			"repeat_code": "D",
			"section_data": [
				{
					"section": "849827",
					"meeting_type": "Lecture",
					"time": "19:00 - 20:50",
					"days": "Monday",
					"building": "PCYNH",
					"room": "109",
					"instructor_name": "Voelker, Geoffrey M.",
					"special_mtg_code": "RE"
				},
				{
					"section": "849827",
					"meeting_type": "Lecture",
					"time": "18:00 - 19:50",
					"days": "Monday",
					"building": "CENTR",
					"room": "214",
					"instructor_name": "Voelker, Geoffrey M.",
					"special_mtg_code": "RE"
				},
				{
					"section": "849827",
					"meeting_type": "Lecture",
					"time": "8:00 - 9:20",
					"days": "Tuesday",
					"building": "CENTR",
					"room": "115",
					"instructor_name": "Voelker, Geoffrey M.",
					"special_mtg_code": ""
				},
				{
					"section": "849827",
					"meeting_type": "Lecture",
					"time": "8:00 - 10:59",
					"days": "Tuesday",
					"building": "CENTR",
					"room": "115",
					"instructor_name": "Voelker, Geoffrey M.",
					"special_mtg_code": "FI"
				},
				{
					"section": "849827",
					"meeting_type": "Lecture",
					"time": "8:00 - 9:20",
					"days": "Thursday",
					"building": "CENTR",
					"room": "115",
					"instructor_name": "Voelker, Geoffrey M.",
					"special_mtg_code": ""
				},
			]
		},
		{
			"term_code": "FA15",
			"subject_code": "CSE",
			"course_code": "131",
			"units": 4,
			"course_level": "UD",
			"grade_option": "L",
			"course_title": "Compiler Construction",
			"enrollment_status": "EN",
			"repeat_code": "D",
			"section_data": [
				{
					"section": "849838",
					"meeting_type": "Lecture",
					"time": "18:30 - 19:50",
					"days": "Monday",
					"building": "GH",
					"room": "242",
					"instructor_name": "Bournoutian, Garo",
					"special_mtg_code": ""
				},
				{
					"section": "849838",
					"meeting_type": "Lecture",
					"time": "19:00 - 21:59",
					"days": "Monday",
					"building": "GH",
					"room": "242",
					"instructor_name": "Bournoutian, Garo",
					"special_mtg_code": "FI"
				},
				{
					"section": "849838",
					"meeting_type": "Lecture",
					"time": "18:30 - 19:50",
					"days": "Wednesday",
					"building": "GH",
					"room": "242",
					"instructor_name": "Bournoutian, Garo",
					"special_mtg_code": ""
				},
			]
		},
		{
			"term_code": "FA15",
			"subject_code": "CSE",
			"course_code": "141",
			"units": 4,
			"course_level": "UD",
			"grade_option": "L",
			"course_title": "Intro/Computer Architecture",
			"enrollment_status": "EN",
			"repeat_code": "D",
			"section_data": [
				{
					"section": "849851",
					"meeting_type": "Discussion",
					"time": "8:00 - 8:50",
					"days": "Friday",
					"building": "WLH",
					"room": "2001",
					"instructor_name": "Porter, Leonard Emerson",
					"special_mtg_code": ""
				}
			]
		},
		{
			"term_code": "FA15",
			"subject_code": "CSE",
			"course_code": "141L",
			"units": 2,
			"course_level": "UD",
			"grade_option": "L",
			"course_title": "Project/Computer Architecture",
			"enrollment_status": "EN",
			"repeat_code": "D",
			"section_data": [
				{
					"section": "849854",
					"meeting_type": "Lecture",
					"time": "15:00 - 15:50",
					"days": "Monday",
					"building": "CENTR",
					"room": "216",
					"instructor_name": "Eldon, John",
					"special_mtg_code": ""
				},
				{
					"section": "849854",
					"meeting_type": "Lecture",
					"time": "15:00 - 17:59",
					"days": "Friday",
					"building": "CENTR",
					"room": "216",
					"instructor_name": "Eldon, John",
					"special_mtg_code": "FI"
				}
			]
		}
	]
};

export function getData() {
	const courses = data.data;
	const enrolledCourses = [];
	const courseItems = {
		Monday: [],
		Tuesday: [],
		Wednesday: [],
		Thursday: [],
		Friday: [],
	};

	// loop thru "data"
	// grab all enrolled classes bc academic history has dropped/waitlisted classes too...
	for (let i = 0; i < courses.length; ++i) {
		if (courses[i].enrollment_status === 'EN') {
			enrolledCourses.push(courses[i]);
		}
	}

	// grab all "section_data" where "special_mtg_code" === ""
	//put into days
	for (let j = 0; j < enrolledCourses.length; ++j) {
		const currCourse = enrolledCourses[j];
		const currSectionData = currCourse.section_data;
		for (let k = 0; k < currSectionData.length; ++k) {
			const currData = currSectionData[k];
			if (currData.special_mtg_code === '') {
				// time format is HH:MM - HH:MM
				// split time string and get seconds
				const timeString = currData.time;
				const timeArr = timeString.split(' ');
				const startString = timeArr[0];
				const endString = timeArr[2];
				const startArr = startString.split(':'); // split it at the colons
				const endArr = endString.split(':'); // split it at the colons
				const startSeconds = (+startArr[0]) * 60 * 60 + (+startArr[1]) * 60;
				const endSeconds = (+endArr[0]) * 60 * 60 + (+endArr[1]) * 60;

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
					special_mtg_code: currData.special_mtg_code
				};

				courseItems[day].push(item);
			}
		}
	}

	// sort by "time"
	const courseItemsKeys = Object.keys(courseItems);
	for (let l = 0; l < courseItemsKeys.length; ++l) {
		const courseItem = courseItems[courseItemsKeys[l]];
		courseItem.sort(sortTime);
	}

	return courseItems;
}

function sortTime(a, b) {
	return a.start_time - b.start_time;
}
