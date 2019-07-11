import React from 'react'
import { View, Dimensions } from 'react-native'
import HeaderRow from './HeaderRow'
import SectionRow from './SectionRow'
import StatusBar from './StatusBar'

const { width } = Dimensions.get('screen')

const CourseDetailView = ({ course, diCode, leIdx, style }) => {
	const { cellWrapperStyle, cellContainerStyle } = styles
	let lectureNum = 0

	return (
		<View style={[cellWrapperStyle, { paddingVertical: 7 }, style]}>
			<View style={cellContainerStyle}>
				<HeaderRow course={course} type="sectionId" style={{ paddingBottom: 6 }} />
				{course.sections.map((section, index) => {
					if (index >= leIdx) {
						const sectionStyle = {
							paddingTop: section.type === 'FINAL' ? 3 : 0,
							paddingBottom: 1
						}
						if (section.type === 'LE') {
							lectureNum += 1
						}
						const isEnrolled = lectureNum <= 1 && (section.sectCode === diCode || section.type === 'LE' || section.type === 'FINAL')
						return isEnrolled && (
							<SectionRow data={section} style={sectionStyle} />
						)
					}
				})}
				<StatusBar data={course.sections[1]} style={{ paddingTop: 2 }} />
			</View>
		</View>
	)
}

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

export default CourseDetailView
