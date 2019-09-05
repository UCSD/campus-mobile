import React, { Component } from 'react'
import {
	View,
	Text,
	Dimensions,
	TouchableWithoutFeedback,
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import CourseTableComponent from './CourseTableComponent'

const { width } = Dimensions.get('screen')

export default class CourseTableView extends Component {
	renderPrereq = () => {
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
		const { data } = this.props
		console.log(data)
		const { containerStyle } = styles
		let currCourse = []
		return (
			<View style={[containerStyle, this.props.style]}>
				{this.renderPrereq()}
				{data.map((sect) => {
					currCourse.push(sect)
					if (sect.FK_SPM_SPCL_MTG_CD === 'FI') {
						const courseSect = <CourseTableComponent course={currCourse} />
						currCourse = []
						return courseSect
					}
					return null
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
		overflow: 'hidden'
	},
	cellWrapperStyle: {
		width: width - 30,
		alignSelf: 'center',
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
		marginBottom: 6,
		backgroundColor: '#FBFBFB',
		borderRadius: 10,
		borderWidth: 1,
		borderColor: 'rgba(0, 0, 0, 0.1)'
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
