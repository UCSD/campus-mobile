import { Text, View, ScrollView, Dimensions, Button } from 'react-native'
import React from 'react'
import auth from '../../../util/auth'
import CourseListMockData from './CourseListMockData.json'
import { getDayOfWeek } from '../../../util/schedule'

const { width, height } = Dimensions.get('window')
const CARD_WIDTH = (width - 70) / 7
const CARD_HEIGHT = 50


const getCourseList = (courses) => {
	/**
	 * @props color    - the border color of current class
	 * @props data     - the complete data of enrolled class
	 * @props type     - 'Calendar' or 'Finals' to show
	 * @props selected - boolean
	 * @props style    - container style
	 */
  let obj = {}
	console.log(courses)

	for(let i in courses) {
		const course = courses[i]

		const {
			subject_code,
			course_code,
			course_level,
			course_title,
			grade_option,
			section_data
		} = course

		section_data.map((item, index) => {
			const {
				section_code,
				meeting_type,
				time,
				days,
				building,
				room,
				special_mtg_code,
				section
			} = item

			let display, type, name, location, duration

			name = subject_code + " " + course_code
			location = building == undefined ? "" : building + " " + room

			// Handle Lectures, Dicussions, and finals
			if( special_mtg_code === "" && meeting_type === "Lecture" ) {
				display = "Calendar"
				type = "LE"
			} else if ( special_mtg_code === "" && meeting_type === "Discussion" ) {
				display = "Calendar"
				type = "DI"
			} else if ( special_mtg_code !== undefined && special_mtg_code === "FI" ) {
				display = "Final"
				type = "FI"
				return
			} else {
				return
			}

			const data = {
				display,
				type,
				name,
				location
			}

			let width, height, x, y, startTime, endTime

			const re = /^([0-2]?[1-9]):([0-5][0-9]) - ([0-2]?[1-9]):([0-5][0-9])$/

			m = re.exec(time)
			if (m) {
				startTime = Number.parseInt(m[1], 10) * 60 - Number.parseInt(m[2], 10)
				endTime = Number.parseInt(m[3], 10) * 60 + Number.parseInt(m[4], 10)
				duration = endTime - startTime
			}
			x = getDayOfWeek(days) * CARD_WIDTH
			y = (startTime / 60 - 7) * (CARD_HEIGHT + 1)
			width  = CARD_WIDTH
			height = CARD_HEIGHT / 60 * duration

			if(!obj[name]) {
				obj[name] = {pressed: false, data: []}
			}
			obj[name].data.push({ x, y, width, height, display, type, name, location })
		})
	}
	return obj

}




class ClassCalendar extends React.Component {
	constructor(props) {
		super(props)
		this.state = { courses: CourseListMockData.data, sample: CourseListMockData.data[0], courseList: getCourseList(CourseListMockData.data) }
	}

	renderCourseCard() {
		const res = []
		for (let item in this.state.courseList) {
			console.log(item)
			res.push(this.state.courseList[item].data.map((course, index) => {
				const { x, y, width, height } = course
				return <View style={{
						backgroundColor: 'blue',
						position: 'absolute',
						top: y,
						left: x,
						width,
						height
					}}></View>
			}))
		}
		return res
	}

	render() {
		const { courses, sample } = this.state
		console.log(this.state.courseList)

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
				<Button onPress={() => auth.retrieveAccessToken().then(credentials => console.log(credentials))} title="Get Access Token" />
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
					{
						this.renderCourseCard()
					}
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
