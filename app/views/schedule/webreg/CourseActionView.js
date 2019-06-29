import React from 'react'
import { View, Text, Dimensions, TouchableOpacity } from 'react-native'
import HeaderRow from './HeaderRow'
import SectionRow from './SectionRow'

const { width } = Dimensions.get('screen')

const CourseActionView = ({ course, sectCode, style }) => {
	const {
		cellWrapperStyle,
		cellContainerStyle,
		buttonContainerStyle,
		buttonStyle,
		borderStyle,
		borderReverseStyle,
		buttonTextStyle,
		selectorStyle,
		selectorButtonStyle
	} = styles
	const buttons = ['View Sections', 'Remove', ['P/NP', 'Letter'], 'Enroll']
	const leftStyle = {
		borderTopLeftRadius: 4,
		borderBottomLeftRadius: 4,
	}
	const rightStyle = {
		borderTopRightRadius: 4,
		borderBottomRightRadius: 4,
	}
	return (
		<View style={[cellWrapperStyle, style, { paddingTop: 7, paddingBottom: 14 }]}>
			<View style={cellContainerStyle}>
				<HeaderRow
					course={course}
					type="sectionId"
					style={{ paddingBottom: 6 }}
					largeText={true}
				/>
				{course.sections.map((section) => {
					const sectionStyle = {
						paddingTop: section.type === 'FINAL' ? 3 : 0,
						paddingBottom: 1
					}
					const isEnrolled = section.type !== 'DI' || section.sectCode === sectCode
					return isEnrolled && (
						<SectionRow data={section} style={sectionStyle} largeText={true} />
					)
				})}
				<View style={buttonContainerStyle}>
					{buttons.map((label, index) => {
						switch (index) {
							case 0: case 1:
								return (
									<TouchableOpacity style={[buttonStyle, borderStyle]}>
										<Text style={buttonTextStyle}>{label}</Text>
									</TouchableOpacity>
								)
							case 2:
								return (
									<View style={selectorStyle}>
										<TouchableOpacity style={[selectorButtonStyle, borderStyle, leftStyle]}>
											<Text style={buttonTextStyle}>{label[0]}</Text>
										</TouchableOpacity>
										<TouchableOpacity style={[selectorButtonStyle, borderReverseStyle, rightStyle]}>
											<Text style={[buttonTextStyle, { color: '#fff' }]}>{label[1]}</Text>
										</TouchableOpacity>
									</View>
								)
							case 3:
								return (
									<TouchableOpacity style={[buttonStyle, borderReverseStyle]}>
										<Text style={[buttonTextStyle, { color: '#fff' }]}>{label}</Text>
									</TouchableOpacity>
								)
							default: return null
						}
					})}
				</View>
			</View>
		</View>
	)
}

export default CourseActionView

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
		width: '83%',
		flexDirection: 'column',
		alignItems: 'center',
		right: 3
	},
	buttonContainerStyle: {
		width: '105%',
		marginVertical: 4,
		flexDirection: 'row',
		flexWrap: 'wrap',
		justifyContent: 'space-between'
	},
	buttonStyle: {
		width: '46%',
		height: 30,
		marginTop: 10,
		borderRadius: 4,
		flexDirection: 'row',
		justifyContent: 'space-around',
		alignItems: 'center',
		overflow: 'hidden'
	},
	borderStyle: {
		borderWidth: 1,
		borderColor: '#034263',
	},
	borderReverseStyle: {
		backgroundColor: '#034263',
		color: '#fff'
	},
	buttonTextStyle: {
		fontSize: 13,
		lineHeight: 15,
		color: '#034263'
	},
	selectorStyle: {
		width: '46%',
		height: 30,
		marginTop: 10,
		flexDirection: 'row',
		justifyContent: 'space-around',
		alignItems: 'center',
		overflow: 'hidden'
	},
	selectorButtonStyle: {
		flex: 1,
		height: '100%',
		justifyContent: 'center',
		alignItems: 'center'
	}
}
