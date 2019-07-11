import React, { Component } from 'react'
import {
	View,
	Text,
	Dimensions,
	TouchableWithoutFeedback,
	Animated,
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'

import SectionRow from './SectionRow'
import CourseTableComponent from './CourseTableComponent'
import Course from './mockData/Course.json'


const { width } = Dimensions.get('screen')

export default class CourseTableView extends Component {
	constructor(props) {
		super(props)
	}
	renderAdditionalMeeting(section) {
		const { cellWrapperStyle, cellContainerStyle, dotStyle } = styles
		return (
			<TouchableWithoutFeedback>
				<View style={cellWrapperStyle}>
					<View style={dotStyle} />
					<View style={cellContainerStyle}>
						<SectionRow data={section} />
					</View>
				</View>
			</TouchableWithoutFeedback>
		)
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
			<Animated.View
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
							return <CourseTableComponent sectIdx={index} />
						}
					})
				}
				{
					Course.sections.map((sect) => {
						switch (sect.type) {
							case 'LE':
								return
							case 'DI':
								return
							default:
								return this.renderAdditionalMeeting(sect)
						}
					})
				}
			</Animated.View>
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
