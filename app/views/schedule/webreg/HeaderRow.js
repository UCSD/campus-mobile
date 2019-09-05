import React from 'react'
import {
	View,
	Text,
	TouchableOpacity
} from 'react-native'

const renderSideBar = (course, type, largeText, sectionId ) => {
	const {
		smallTextStyle,
		largeTextStyle,
		buttonStyle,
		buttonReverseStyle,
		smallButtonTextStyle,
		largeButtonTextStyle
	} = styles
	const textStyle = largeText ? largeTextStyle : smallTextStyle
	const buttonTextStyle = largeText ? largeButtonTextStyle : smallButtonTextStyle

	switch (type) {
		case 'sectionId':
			return (
				<View style={{ flexDirection: 'row' }}>
					<Text style={[textStyle, { color: '#7D7D7D' }]}>Section ID </Text>
					<Text style={[textStyle, { color: '#000' }]}>{sectionId}</Text>
				</View>
			)
		case 'buttons':
			return (
				<View style={{ flexDirection: 'row' }}>
					<TouchableOpacity style={buttonReverseStyle}>
						<Text style={buttonTextStyle}>Note</Text>
					</TouchableOpacity>
					<TouchableOpacity style={buttonStyle}>
						<Text style={buttonTextStyle}>Prereq</Text>
					</TouchableOpacity>
					<TouchableOpacity style={buttonStyle}>
						<Text style={buttonTextStyle}>Level</Text>
					</TouchableOpacity>
				</View>
			)
		default:
			return (
				<TouchableOpacity style={buttonStyle}>
					<Text style={buttonTextStyle}>Note</Text>
				</TouchableOpacity>
			)
	}
}

const HeaderRow = ({ course, style, type, largeText, sectionId }) => {
	const {
		containerStyle,
		smallTextStyle,
		largeTextStyle,
		buttonContainerStyle,
	} = styles

	return (
		<View style={[containerStyle, style]}>
			<Text style={largeText ? largeTextStyle : smallTextStyle}>
				{course.PERSON_FULL_NAME}
			</Text>
			<View style={buttonContainerStyle}>
				{renderSideBar(course, type, largeText, sectionId)}
			</View>
		</View>
	)
}

const styles = {
	containerStyle: {
		width: '100%',
		flexDirection: 'row',
		justifyContent: 'space-between',
		alignItems: 'center',
		paddingVertical: 7
	},
	smallTextStyle: {
		fontSize: 12,
		lineHeight: 14,
		color: '#034263'
	},
	largeTextStyle: {
		fontSize: 14,
		lineHeight: 16,
		color: '#034263'
	},
	buttonContainerStyle: {
		flexDirection: 'row'
	},
	buttonStyle: {
		width: 52,
		height: 16,
		borderWidth: 0.5,
		borderColor: '#034263',
		borderRadius: 3,
		boxSizing: 'border-box',
		justifyContent: 'center',
		alignItems: 'center'
	},
	buttonReverseStyle: {
		width: 52,
		height: 16,
		backgroundColor: '#034263',
		borderRadius: 3,
		justifyContent: 'center',
		alignItems: 'center'
	},
	smallButtonTextStyle: {
		fontSize: 10,
		lineHeight: 12,
		color: '#034263',
	},
	largeButtonTextStyle: {
		fontSize: 12,
		lineHeight: 14,
		color: '#034263',
	},
}

export default HeaderRow
