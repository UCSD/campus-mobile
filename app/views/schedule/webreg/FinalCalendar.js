import { Text, View, ScrollView } from 'react-native'
import React from 'react'

class ClassCalendar extends React.Component {
	constructor(props) {
		super(props)
	}

	render() {
		const days = ['Sat', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
		const hours = ['7 am', '8 am', '9 am', '10 am', '11 am', '12 pm', '1 pm', '2 pm', '3 pm', '4 pm', '5 pm', '6 pm', '7 pm', '8 pm', '9 pm']

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
						<View style={dayContainerStyle} key={day}>
							<Text style={dayTextStyle}>{day}</Text>
						</View>
					))}
				</View>
				<ScrollView style={{ flex: 1 }}>
					{hours.map((hour, i) => (
						<View style={[timeRowStyle, { borderBottomWidth: i === 13 ? 1 : 0 }]} key={hour}>
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
		marginLeft: 20,
		marginRight: 20
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
		borderColor: '#B7B7B7'
	},
	timeContainerStyle: {
		width: 30,
		justifyContent: 'center',
		alignItems: 'center',
	},
	timeTextStyle: {
		fontFamily: 'Helvetica Neue',
		textColor: 'black',
		paddingTop: 25,
		paddingBottom: 25,
		fontSize: 10
	}
}

export default ClassCalendar
