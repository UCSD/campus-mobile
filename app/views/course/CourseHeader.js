import React from 'react'
import { View, Text } from 'react-native'

const CourseHeader = ({ course, terms, style }) => {
	const {
		containerStyle,
		unitBGStyle,
		unitFontStyle,
		courseContainerStyle,
		titleStyle,
		descriptionStyle,
		termStyle,
		termFontStyle,
	} = styles
	return (
		<View style={[containerStyle, style]}>
			<View style={unitBGStyle}>
				<Text style={unitFontStyle}>{course.unit}</Text>
			</View>
			<View style={courseContainerStyle}>
				<Text style={titleStyle}>{course.courseCode}</Text>
				<Text style={descriptionStyle}>{course.courseName}</Text>
			</View>

			{terms !== null &&
				<View style={termStyle}>
					<Text style={termFontStyle}>{terms}</Text>
				</View>
			}
		</View>
	)
}

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
		width: '85%',
		borderRadius: 10,
		backgroundColor: '#FBFBFB',
		paddingTop: 3,
		paddingLeft: 12,
		paddingBottom: 6
	},
	unitBGStyle: {
		width: 28,
		height: 28,
		borderRadius: 14,
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: '#EAEAEA',
	},
	unitFontStyle: {
		fontSize: 14,
		lineHeight: 16
	},
	courseContainerStyle: {
		flexDirection: 'column',
		marginLeft: 13,
	},
	titleStyle: {
		fontSize: 18,
		lineHeight: 21,
		fontWeight: 'bold',
	},
	descriptionStyle: {
		fontSize: 14,
		lineHeight: 16,
	},
	termStyle: {
		position: 'absolute',
		top: 6,
		right: 7
	},
	termFontStyle: {
		color: '#7D7D7D',
		fontSize: 12,
		lineHeight: 14,
	}
}
export default CourseHeader