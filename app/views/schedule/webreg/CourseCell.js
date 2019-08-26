import React from 'react'

import CourseTitle from './common/CourseTitle'


const CourseCell = ({ course = { SUBJ_CODE: 'undefined', CRSE_CODE: 'undefined', CRSE_TITLE: 'undefined', UNIT_TO: '0' }, term, style }) =>
	(
		<CourseTitle
			unit={course.UNIT_TO}
			code={`${course.SUBJ_CODE}${course.CRSE_CODE}`}
			title={course.CRSE_TITLE}
			containerStyle={styles.containerStyle}
			term={term}
		/>
	)

const styles = {
	containerStyle: {
		height: 60,
		paddingHorizontal: '6%',
		alignSelf: 'center',
		borderBottomWidth: 1,
		borderColor: '#EAEAEA',
	},
}

export default CourseCell
