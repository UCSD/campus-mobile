import React from 'react'
import { View, Text, Dimensions, TouchableOpacity } from 'react-native'
// import { getScreenWidth } from '../../../util/general'

const { width } = Dimensions.get('screen')

const CourseActionView = ({ style }) => {
	const {
		cellWrapperStyle,
		buttonStyle,
		borderStyle,
		borderReverseStyle,
		buttonTextStyle,
		selectorStyle,
		selectorButtonStyle
	} = styles
	const buttons = ['Plan', 'Remove', ['P/NP', 'Letter'], 'Enroll']
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
	)
}

export default CourseActionView

const styles = {
	cellWrapperStyle: {
		width,
		paddingHorizontal: width * 0.1,
		flexDirection: 'row',
		flexWrap: 'wrap',
		justifyContent: 'space-between',
		alignSelf: 'center',
		alignItems: 'center',
		backgroundColor: '#FBFBFB',
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
