import React from 'react'

import CourseTitle from './common/CourseTitle'


const CourseCell = ({ course = { unit: -1, courseCode: 'undefined', title: 'undefined' }, term }) =>
	 (
		<CourseTitle
			unit={course.unit}
			code={course.courseCode}
			title={course.courseName}
			containerStyle={styles.containerStyle}
			term={term}
		/>
	)


const styles = {
	containerStyle: {
		alignSelf: 'center',
		flexDirection: 'row',
		alignItems: 'center',
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 1,
		},
		shadowOpacity: 0.1,
		shadowRadius: 2,
		width: '88%',
		borderRadius: 10,
		backgroundColor: '#FBFBFB',
		paddingTop: 3,
		paddingLeft: 6,
		paddingBottom: 3
	},
}

export default CourseCell
