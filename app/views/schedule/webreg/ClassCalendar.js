import { Text, View, ScrollView } from 'react-native'
import React from 'react'

class ClassCalendar extends React.Component {
	render() {
		const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
		const hours = ['8:00', '9:00', '10:00', '11:00', '12:00', '1:00', '2:00', '3:00', '4:00', '5:00', '6:00', '7:00', '8:00', '9:00']

		const {
			cardStyle,
			daysContainerStyle,
			dayContainerStyle,
			dayTextStyle,
			timeTextStyle,
			timeRowStyle,
			timeContainerStyle
		} = styles

		return (
			<View style={cardStyle}>
				<View style={daysContainerStyle}>
					{days.map((day, i) => (
						<View style={dayContainerStyle} key={i}>
							<Text style={dayTextStyle}>{day}</Text>
						</View>
					))}
				</View>
				<ScrollView>
					{hours.map((hour, i) => (
						<View style={[timeRowStyle, { borderBottomWidth: i === 13 ? 1 : 0 }]} key={i}>
							<View style={timeContainerStyle}>
								<Text style={timeTextStyle}>
									{hour}
								</Text>
							</View>
						</View>
					))}
				</ScrollView>
			</View>
		)
	}
}

const styles = {
	cardStyle: {
		flex: 1,
		marginLeft: 5,
		marginRight: 5
	},
	daysContainerStyle: {
		marginLeft: 30,
		flexDirection: 'row',
	},
	dayContainerStyle: {
		flex: 1 / 7,
		justifyContent: 'center',
		alignItems: 'center'
	},
	dayTextStyle: {
		fontFamily: 'Helvetica Neue',
		textColor: 'black',
		paddingTop: 10,
		paddingBottom: 10,
		fontSize: 10
	},
	timeRowStyle: {
		flexDirection: 'row',
		borderTopWidth: 1,
		borderColor: '#aaa'
	},
	timeContainerStyle: {
		width: 30,
		justifyContent: 'center',
		alignItems: 'center',
	},
	timeTextStyle: {
		fontFamily: 'Helvetica Neue',
		textColor: 'black',
		paddingTop: 30,
		paddingBottom: 30,
		fontSize: 10
	}
}

export default ClassCalendar
