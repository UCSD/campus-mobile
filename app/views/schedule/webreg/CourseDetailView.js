import React from 'react'
import { View, Dimensions } from 'react-native'
import HeaderRow from './HeaderRow'
import SectionRow from './SectionRow'
import StatusBar from './StatusBar'
import { getScreenWidth } from '../../../util/general'

const { width } = getScreenWidth()

const CourseDetailView = ({ course, sectCode, style }) => {
	const { cellWrapperStyle, cellContainerStyle } = styles
	return (
		<View style={[cellWrapperStyle, { paddingVertical: 7 }, style]}>
			<View style={cellContainerStyle}>
				<HeaderRow course={course} type="sectionId" style={{ paddingBottom: 6 }} />
				{course.sections.map((section) => {
					const sectionStyle = {
						paddingTop: section.type === 'FINAL' ? 3 : 0,
						paddingBottom: 1
					}
					const isEnrolled = section.type !== 'DI' || section.sectCode === sectCode
					return isEnrolled && (
						<SectionRow data={section} style={sectionStyle} />
					)
				})}
				<StatusBar data={course.sections[1]} style={{ paddingTop: 2 }} />
			</View>
		</View>
	)
}

export default CourseDetailView

const styles = {
	cellWrapperStyle: {
		width: width - 32,
		alignSelf: 'center',
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: '#FBFBFB',
		borderRadius: 10,
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 2
		},
		shadowRadius: 5,
		shadowOpacity: 0.1
	},
	cellContainerStyle: {
		width: '73%',
		flexDirection: 'column',
		right: 3
	},
}
