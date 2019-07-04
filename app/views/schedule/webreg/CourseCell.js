import React from 'react'
// import css from '../../../styles/css'

import CourseTitle from './common/CourseTitle'


const CourseCell = ({ course, terms }) =>
	// return (
	// 	<View style={[containerStyle, style]}>
	// 		<View style={css.webreg_common_unit_bg}>
	// 			<Text style={css.webreg_common_unit_text}>{course.unit}</Text>
	// 		</View>
	// 		<View style={courseContainerStyle}>
	// 			<Text style={titleStyle}>{course.courseCode}</Text>
	// 			<Text style={descriptionStyle}>{course.courseName}</Text>
	// 		</View>

	// 		{terms !== null &&
	// 			<View style={termStyle}>
	// 				<Text style={termFontStyle}>{terms}</Text>
	// 			</View>
	// 		}
	// 	</View>
	// )

	 (
		<CourseTitle
			unit={course.unit}
			code={course.courseCode}
			title={course.courseName}
			containerStyle={styles.containerStyle}
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
	// courseContainerStyle: {
	// 	flexDirection: 'column',
	// 	marginLeft: 13,
	// },
	// titleStyle: {
	// 	fontSize: 18,
	// 	lineHeight: 21,
	// 	fontWeight: 'bold',
	// },
	// descriptionStyle: {
	// 	fontSize: 14,
	// 	lineHeight: 16,
	// },
	// termStyle: {
	// 	position: 'absolute',
	// 	top: 6,
	// 	right: 7
	// },
	// termFontStyle: {
	// 	color: '#7D7D7D',
	// 	fontSize: 12,
	// 	lineHeight: 14,
	// }
}

export default CourseCell
