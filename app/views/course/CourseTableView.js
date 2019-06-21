/* eslint-disable class-methods-use-this */
import React, { Component } from 'react'
import { View, Text, Image, Animated, Dimensions, TouchableWithoutFeedback } from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import HeaderRow from './HeaderRow'
import SectionRow from './SectionRow'
import StatusBar from './StatusBar'
import Course from './Course.json'
import ExpandArrow from './icons8-expand-arrow-filled-500.png'

const { width } = Dimensions.get('screen')

export default class CourseTableView extends Component {
	constructor() {
		super()
		this.state = {
			expanded: false
		}
		this._onPress = this._onPress.bind(this)
	}

	_onPress = () => {
		this.setState(prevState => ({
			expanded: !prevState.expanded
		}))
	}

	renderLecture(course, section) {
		const { cellWrapperStyle, cellContainerStyle, dotStyle, expandIconStyle } = styles
		return (
			<TouchableWithoutFeedback onPress={this._onPress}>
				<View style={[cellWrapperStyle, { paddingTop: 4, paddingBottom: 7 }]}>
					<View style={dotStyle} />
					<View style={cellContainerStyle}>
						<HeaderRow course={course} />
						<SectionRow data={section} />
					</View>
					<Icon name="play-arrow" size={25} color="#034263" style={expandIconStyle} />
				</View>
			</TouchableWithoutFeedback>
		)
	}

	renderEnrollment(section) {
		const { cellWrapperStyle, cellContainerStyle, navIconStyle } = styles
		return (
			<TouchableWithoutFeedback>
				<View style={cellWrapperStyle}>
					<View style={cellContainerStyle}>
						<SectionRow data={section} style={{ paddingBottom: 3 }} />
						<StatusBar data={section} />
					</View>
					<Image source={ExpandArrow} style={navIconStyle} />
				</View>
			</TouchableWithoutFeedback>
		)
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
			<TouchableWithoutFeedback>
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
			<View style={[containerStyle, this.props.style]}>
				{this.renderPrereq()}
				{Course.sections.map((sect) => {
					switch (sect.type) {
						case 'LE':
							return this.renderLecture(Course, sect)
						case 'DI':
							return this.state.expanded && this.renderEnrollment(sect)
						default:
							return this.renderAdditionalMeeting(sect)
					}
				})}
			</View>
		)
	}
}

const styles = {
	containerStyle: {
		flexDirection: 'column',
		justifyContent: 'flex-start',
		alignItems: 'center',
	},
	cellWrapperStyle: {
		width: width - 32,
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
		marginVertical: 4,
		marginHorizontal: 16,
		backgroundColor: '#fff',
		borderRadius: 10,
		shadowColor: '#000000',
		shadowOffset: {
			width: 0,
			height: 2
		},
		shadowRadius: 2,
		shadowOpacity: 0.2
	},
	cellContainerStyle: {
		width: '73%',
		flexDirection: 'column',
		right: 3
	},
	expandIconStyle: {
		position: 'absolute',
		bottom: 7,
		right: 16,
		transform: [{ rotate: '180deg' }],
	},
	navIconStyle: {
		width: 20,
		height: 20,
		position: 'absolute',
		right: 15,
		transform: [{ rotate: '-90deg' }],
		tintColor: '#BEBEBE'
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
