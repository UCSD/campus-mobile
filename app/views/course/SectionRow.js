import React from 'react'
import { View, Text } from 'react-native'

const SectionRow = ({ data, style, largeText }) => {
	const {
		containerStyle,
		textStyle,
		largeTextStyle,
		dayStyle,
		timeStyle,
		locationStyle
	} = styles
	const labelTextStyle = largeText ? largeTextStyle : textStyle
	const days = ['M', 'Tu', 'W', 'Th', 'F']
	return (
		<View style={[containerStyle, style]}>
			{data.type !== 'FINAL' ? (
				<View style={{ flexDirection: 'row' }}>
					<Text style={[labelTextStyle, { color: '#7D7D7D' }]}>{data.sectCode} </Text>
					<Text style={labelTextStyle}>{data.type}</Text>
				</View>
			) : (
				<Text style={[labelTextStyle, { color: '#7D7D7D' }]}>{data.type}</Text>
			)}

			<View style={[dayStyle, { flexDirection: 'row' }]}>
				{data.type !== 'FINAL' ? (
					days.map((str) => {
						const dayTextstyle = [
							labelTextStyle,
							{ color: data.dayCode.includes(str) ? '#034263' : '#EAEAEA' }
						]
						return (
							<Text style={dayTextstyle}>{str.charAt(0)} </Text>
						)
					})
				) : (
					<Text style={[labelTextStyle, { color: '#034263' }]}>{data.dayCode}</Text>
				)}
			</View>
			<Text style={[labelTextStyle, timeStyle]}>{data.time}</Text>
			<Text style={[labelTextStyle, locationStyle]}>{data.bldg} {data.room}</Text>
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
	textStyle: {
		fontSize: 10,
		lineHeight: 12,
	},
	largeTextStyle: {
		fontSize: 12,
		lineHeight: 14,
	},
	dayStyle: {
		flexDirection: 'row',
		position: 'absolute',
		left: '22%'
	},
	timeStyle: {
		position: 'absolute',
		left: '49%'
	},
	locationStyle: {
		position: 'absolute',
		left: '80%'
	}
}

export default SectionRow
