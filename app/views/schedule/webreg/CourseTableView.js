import React, { Component } from 'react'
import {
	View,
	Text,
	Dimensions,
	TouchableWithoutFeedback,
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import CourseTableComponent from './CourseTableComponent'
import Course from './mockData/Course.json'


const { width } = Dimensions.get('screen')

export default class CourseTableView extends Component {
	constructor() {
		super()
	}

	renderPrereq() {
		const { cellWrapperStyle, cellContainerStyle, expandIconStyle, prereqTextStyle } = styles
		return (
			<TouchableWithoutFeedback >
				<View style={[cellWrapperStyle, { marginBottom: 12 }]}>
					<View style={cellContainerStyle}>
						<Text style={prereqTextStyle}>Course Prerequisites & Level Restrictions</Text>
					</View>
					<Icon name="play-arrow" size={25} color="#034263" style={expandIconStyle} />
				</View>
			</TouchableWithoutFeedback>
		)
	}

	render() {
		const { containerStyle } = styles
		return (
			<View
				style={
					[
						containerStyle,
						this.props.style,
					]
				}
			>
				{this.renderPrereq()}
				{
					Course.sections.map((sect, index) => {
						if (sect.type === 'LE') {
							console.log('LE', index)
							return <CourseTableComponent course={Course} lecIdx={index} />
						}
					})
				}
			</View>
		)
	}
}

const styles = {
	containerStyle: {
		flexDirection: 'column',
		justifyContent: 'flex-start',
		alignItems: 'center',
		overflow: 'hidden'
	},
	cellWrapperStyle: {
		width: width - 32,
		alignSelf: 'center',
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
		marginBottom: 6,
		backgroundColor: '#FBFBFB',
		borderRadius: 10,
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 2
		},
		shadowRadius: 5,
		shadowOpacity: 0.1,
	},
	cellContainerStyle: {
		width: '73%',
		flexDirection: 'column',
		right: 3,
	},
	expandIconStyle: {
		position: 'absolute',
		bottom: 7,
		right: 16,
		transform: [{ rotate: '180deg' }],
	},
	dotStyle: {
		width: 8,
		height: 8,
		borderWidth: 1,
		borderColor: '#034263',
		borderRadius: 4,
		position: 'absolute',
		left: 16,
	},
	prereqTextStyle: {
		fontSize: 12,
		lineHeight: 14,
		fontWeight: 'bold',
		color: '#034263',
		marginTop: 13,
		marginBottom: 12
	}
}
