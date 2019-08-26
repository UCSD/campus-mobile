import React from 'react'

import CourseTitle from './common/CourseTitle'


const CourseCell = ({ course = { unit: -1, courseCode: 'undefined', title: 'undefined' }, term, style }) =>
	 (
		<CourseTitle
			unit={course.unit}
			code={course.courseCode}
			title={course.courseName}
			containerStyle={[styles.containerStyle, style]}
			term={term}
		/>
	)


const styles = {
	containerStyle: {
		alignSelf: 'center',
		flexDirection: 'row',
		alignItems: 'center',
		borderRadius: 10,
		// backgroundColor: '#FBFBFB',
		paddingVertical: 6,
		paddingHorizontal: 6,
	},
}

export default CourseCell
