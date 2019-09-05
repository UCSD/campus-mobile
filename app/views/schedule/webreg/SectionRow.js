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
	const dayComplete = ['Mon', 'Tue', 'Wed', 'Thurs', 'Fri']
	const renderTime = () => {
		const startSuffix =  data.BEGIN_HH_TIME >= 12 ? 'p' : 'a'
		const endSuffix = data.END_HH_TIME >= 12 ? 'p' : 'a'
		const startH = data.BEGIN_HH_TIME > 12 ? (data.BEGIN_HH_TIME - 12 ) : data.BEGIN_HH_TIME
		const startM = data.BEGIN_MM_TIME === 0 ? '00' : data.BEGIN_MM_TIME
		const endH = data.END_HH_TIME > 12 ? (data.END_HH_TIME - 12) : data.END_HH_TIME
		const endM =  data.END_MM_TIME === 0 ? '00' : data.END_MM_TIME
		return `${startH}:${startM}${startSuffix}-${endH}:${endM}${endSuffix}`
	}
	return (
		<View style={[containerStyle, style]}>
			{data.FK_SPM_SPCL_MTG_CD !== 'FI' ? (
				<View style={{ flexDirection: 'row' }}>
					<Text style={[labelTextStyle, { color: '#7D7D7D' }]}>{data.SECT_CODE} </Text>
					<Text style={labelTextStyle}>{data.FK_CDI_INSTR_TYPE}</Text>
				</View>
			) : (
				<Text style={[labelTextStyle, { color: '#7D7D7D' }]}>FINAL</Text>
			)}

			<View style={[dayStyle, { flexDirection: 'row' }]}>
				{data.FK_SPM_SPCL_MTG_CD !== 'FI' ? (
					days.map((str, index) => {
						const dayTextstyle = [
							labelTextStyle,
							{ color: data.DAY_CODE.includes( index + 1 ) ? '#034263' : '#EAEAEA' }
						]
						return (
							<Text style={dayTextstyle}>{str.charAt(0)} </Text>
						)
					})
				) : (
					<Text style={[labelTextStyle, { color: '#034263' }]}>{dayComplete[data.DAY_CODE - 1]}</Text>
				)}
			</View>
			<Text style={[labelTextStyle, timeStyle]}>{renderTime()}</Text>
			<Text style={[labelTextStyle, locationStyle]}>{data.BLDG_CODE} {data.ROOM_CODE}</Text>
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
