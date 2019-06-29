import React from 'react'
import { View, Text } from 'react-native'

const renderBar = (data) => {
	const {
		barContainerStyle,
		barStyle,
		leftBarStyle,
		rightBarStyle
	} = styles

	const { availSeats, waitlistCount, totalSeats } = data

	if (availSeats > 0 || waitlistCount > 0) {
		const percentage = ((Math.max(availSeats, waitlistCount) / totalSeats) * 100)
		const leftStyle = {
			width: (100 - percentage) + '%',
			marginRight: 1
		}
		const rightStyle = {
			width: percentage + '%',
			backgroundColor: waitlistCount > 0 ? '#D27070' : '#C4C4C4',
		}
		return (
			<View style={barContainerStyle}>
				<View style={[leftBarStyle, leftStyle]} />
				<View style={[rightBarStyle, rightStyle]} />
			</View>
		)
	}

	return (
		<View style={barContainerStyle}>
			<View style={[barStyle]} />
		</View>
	)
}

const StatusBar = ({ data, style }) => {
	const {
		containerStyle,
		labelsConatainerStyle,
		textStyle
	} = styles
	const { availSeats, waitlistCount, totalSeats } = data

	return (
		<View style={[containerStyle, style]}>
			<View style={labelsConatainerStyle}>
				<Text style={[textStyle, { color: '#034263' }]}>Available {availSeats}</Text>
				<Text style={[textStyle, { color: '#7D7D7D' }]}>Total {totalSeats}</Text>
				<Text style={[textStyle, { color: waitlistCount > 0 ? '#D27070' : '#C4C4C4' }]}>
					{waitlistCount > 0 ? 'Waitlist ' + waitlistCount : 'Enrolled ' + (totalSeats - availSeats)}
				</Text>
			</View>
			{renderBar(data)}
		</View>
	)
}

const styles = {
	containerStyle: {
		width: '100%',
		paddingBottom: 8,
	},
	labelsConatainerStyle: {
		width: '100%',
		flexDirection: 'row',
		justifyContent: 'space-between',
	},
	textStyle: {
		fontSize: 9,
		lineHeight: 11,
	},
	barContainerStyle: {
		width: '100%',
		flexDirection: 'row'
	},
	barStyle: {
		height: 2,
		borderRadius: 1,
		backgroundColor: '#034263'
	},
	leftBarStyle: {
		height: 2,
		borderTopLeftRadius: 1,
		borderBottomLeftRadius: 1,
		backgroundColor: '#034263'
	},
	rightBarStyle: {
		height: 2,
		borderTopRightRadius: 1,
		borderBottomRightRadius: 1,
	}
}

export default StatusBar
