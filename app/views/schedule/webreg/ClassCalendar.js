import { Text, View, ScrollView, Dimensions } from 'react-native'
import React from 'react'

const { width, height } = Dimensions.get('window')
const CARD_WIDTH = (width - 70) / 7
const CARD_HEIGHT = 50


class ClassCalendar extends React.Component {
	constructor(props) {
		super(props)
	}

	render() {
		const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
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
			<View style={[cardStyle]}>
				<View style={daysContainerStyle}>
					{days.map((day, i) => (
						<View style={dayContainerStyle} key={day}>
							<Text style={dayTextStyle}>{day}</Text>
						</View>
					))}
				</View>
				<ScrollView
					style={{flex:1}}
					showsVerticalScrollIndicator={false}
				>

					<View style={{
							flexDirection: 'row',
							flex: 1,
							justifyContent: 'flex-start',
						}}>
						<View style={{
								flex: 1/7,
								flexDirection: 'column',
								alignItems: 'stretch',
								justifyContent: 'center'
							}}>
							{hours.map((hour, i) => (
								<View style={[timeRowStyle, { borderBottomWidth: i === 14 ? 1 : 0 }]} key={hour}>
									<View style={timeContainerStyle}>
										<Text style={timeTextStyle}>
											{hour}
										</Text>
									</View>
								</View>
							))}
						</View>
						{
							days.map((item, index) => {
								console.log('ahahah');
								return (
								<View style={{
										flex: 1/7,
										flexDirection: 'column',
										alignItems: 'stretch',
										justifyContent: 'center'
									}}>
									{hours.map((hour, i) => (
										<View style={[timeRowStyle, { borderBottomWidth: i === 14 ? 1 : 0 }]} key={hour}>
											<View style={timeContainerStyle}>
												<View style={{ height: 50 }}>

												</View>
											</View>
										</View>
									))}
								</View>)
						})
					}
				</View>

					{/*
					<ScrollView style={{ flex: 1 }}>
						{hours.map((hour, i) => (
							<View style={[timeRowStyle, { borderBottomWidth: i === 14 ? 1 : 0 }]} key={hour}>
								<View style={timeContainerStyle}>
									<Text style={timeTextStyle}>
										{hour}
									</Text>
								</View>
							</View>
						))}
					</ScrollView>
					*/}
					<View style={{
							backgroundColor: 'red',
							position: 'absolute',
							top: 400,
							left: 70,
							width: CARD_WIDTH,
							height: CARD_HEIGHT
						}}></View>
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
		height: 50,
		justifyContent: 'center',
		alignItems: 'center',
	},
	timeTextStyle: {
		fontFamily: 'Helvetica Neue',
		textColor: 'black',
		fontSize: 10
	}
}

export default ClassCalendar
