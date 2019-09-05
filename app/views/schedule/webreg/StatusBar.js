import React from 'react'
import { View, Text } from 'react-native'

const renderBar = (data) => {
	const {
		barContainerStyle,
		barStyle,
		leftBarStyle,
		rightBarStyle
	} = styles

	const { AVAIL_SEAT, COUNT_ON_WAITLIST, SCTN_ENRLT_QTY } = data

	if (AVAIL_SEAT > 0 || COUNT_ON_WAITLIST > 0) {
		const percentage = ((Math.max(AVAIL_SEAT, COUNT_ON_WAITLIST) / SCTN_ENRLT_QTY) * 100)
		const leftStyle = {
			width: (100 - percentage) + '%',
			marginRight: 1
		}
		const rightStyle = {
			width: percentage + '%',
			backgroundColor: COUNT_ON_WAITLIST > 0 ? '#D27070' : '#C4C4C4',
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
	const { AVAIL_SEAT, COUNT_ON_WAITLIST, SCTN_ENRLT_QTY } = data

	return (
		<View style={[containerStyle, style]}>
			<View style={labelsConatainerStyle}>
				<Text style={[textStyle, { color: '#034263' }]}>Available {AVAIL_SEAT}</Text>
				<Text style={[textStyle, { color: '#7D7D7D' }]}>Total {SCTN_ENRLT_QTY}</Text>
				<Text style={[textStyle, { color: COUNT_ON_WAITLIST > 0 ? '#D27070' : '#C4C4C4' }]}>
					{COUNT_ON_WAITLIST > 0 ? 'Waitlist ' + COUNT_ON_WAITLIST : 'Enrolled ' + (SCTN_ENRLT_QTY - AVAIL_SEAT)}
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
