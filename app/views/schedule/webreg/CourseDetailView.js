import React from 'react'
import { View, Dimensions } from 'react-native'
import HeaderRow from './HeaderRow'
import SectionRow from './SectionRow'
import StatusBar from './StatusBar'

const { width } = Dimensions.get('screen')

const CourseDetailView = ({ course, diIndex, style }) => {
	const { cellWrapperStyle, cellContainerStyle } = styles

	return (
		<View style={[cellWrapperStyle, { paddingVertical: 7 }, style]}>
			<View style={cellContainerStyle}>
				<HeaderRow course={course[0]} type="sectionId" style={{ paddingBottom: 6 }} sectionId={course[diIndex].SECTION_NUMBER} />
				{course.map((section, index) => {
					if (index === diIndex || section.FK_CDI_INSTR_TYPE === 'LE') {
						const sectionStyle = {
							paddingTop: section.FK_SPM_SPCL_MTG_CD === 'FI' ? 3 : 0,
							paddingBottom: 1
						}
						return (
							<SectionRow data={section} style={sectionStyle} />
						)
					} else {
						return null
					}
				})}
				<StatusBar data={course[diIndex]} style={{ paddingTop: 2 }} />
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
		borderWidth: 1,
		borderColor: 'rgba(0, 0, 0, 0.1)',
		marginBottom: 12,
	},
	cellContainerStyle: {
		width: '73%',
		flexDirection: 'column',
		right: 3
	},
}

export default CourseDetailView
