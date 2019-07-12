import { Text, View, ScrollView, Dimensions, TouchableWithoutFeedback } from 'react-native'
import React from 'react'
import { connect } from 'react-redux'
import Icon from 'react-native-vector-icons/FontAwesome'

import CourseListMockData from './mockData/CourseListMockData.json'
import { getDayOfWeek, getCourseList } from '../../../util/schedule'
import { getScreenWidth, getScreenHeight } from '../../../util/general'
import CalendarCard from './CalendarCard'

const width = getScreenWidth()
const height = getScreenHeight()
const CARD_WIDTH = (width - 70) / 7
const CARD_HEIGHT = 50
const COLOR_LIST = ['#ffdfba', '#ffffba', '#baffc9', '#bae1ff', 'rgb(193, 224, 252)']

class ClassCalendar extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			courses: CourseListMockData.data,
			sample: CourseListMockData.data[0],
			courseList: getCourseList(CourseListMockData.data, false, CARD_WIDTH, CARD_HEIGHT)
		}
	}

	componentWillMount() {
		this.props.resetCourseCard()
	}

	renderCourseCard() {
		const res = []
		Object.keys(this.state.courseList).map((item, i) => {
			this.state.courseList[item].data.map((course, index) => {
				const { color = 0, name, location, display, type, selected, x, y, height, width, status = 'enrolled' } = course

				const onLayout = (event) => {
					const { x, y, width, height } = event.nativeEvent.layout
					// console.log('onLayout,', { name, x, y, width, height })
					this.props.updateCourseCard(name, x, y, width, height)
				}

				if (this.props.selectedCourse && this.props.selectedCourse === name) {
					res.push(<CalendarCard
						selected
						color={COLOR_LIST[color % COLOR_LIST.length]}
						name={name}
						location={location}
						display={display}
						type={type}
						x={x}
						y={y}
						height={height}
						width={width}
						status={status}
						onPress={() => {
							this.props.selectCourse(name, this.state.courseList[item].course)
							this.setState({ courseList: { ...this.state.courseList, [name]: { ...this.state.courseList[name], selected: !this.state.courseList[item].selected } } })
						}}
						onLayout={onLayout}
						zIndex
					/>)

					// Check if the course is overlapping with some other course(s)
					if (this.props.courseCards) {
						const conflict = []
						Object.keys(this.props.courseCards).map((courseName, i) => {
							const course = this.props.courseCards[courseName]
							course.map((info, idx) => {
								if (name === courseName) return null
								const { x: courseX, y: courseY } = info
								if (Math.abs(courseX - x) <= 1 && Math.abs(courseY - y) <= 1 ) {
									console.log('comparing course card coordinates', courseName, courseX, courseY, x, y)
									conflict.push(courseName)
								}
								return null
							})
							return null
						})
						const sortedConflict = [...conflict]
						sortedConflict.push(name)
						sortedConflict.sort()
						const indexOfName = sortedConflict.indexOf(name)

						console.log('sortedConflict array', sortedConflict)
						if (sortedConflict.length > 1) {
							res.push(<Icon
								style={{
									position: 'absolute',
									left: x + (width * 0.8),
									top: y - (height / 7.5),
									zIndex: 2
								}}
								name="refresh"
								size={18}
								onPress={() => {
									const nextCourse = sortedConflict[(indexOfName + 1) % sortedConflict.length]
									this.props.selectCourse(nextCourse, this.state.courseList[nextCourse].course)
								}}
							/>)
						}
					}
				} else {
					res.push(<CalendarCard
						color={COLOR_LIST[color % COLOR_LIST.length]}
						name={name}
						location={location}
						display={display}
						type={type}
						x={x}
						y={y}
						height={height}
						width={width}
						status={status}
						onPress={() => {
							this.props.selectCourse(name, this.state.courseList[item].course)
							this.setState({ courseList: { ...this.state.courseList, [name]: { ...this.state.courseList[name], selected: !this.state.courseList[item].selected } } })
						}}
						onLayout={onLayout}
					/>)
				}
				return null
			})
			return null
		})
		return res
	}

	render() {
		const { courses, sample } = this.state
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
			<View style={cardStyle}>
				{ /* <Button onPress={() => auth.retrieveAccessToken().then(credentials => console.log(credentials))} title="Get Access Token" /> */}
				<View style={daysContainerStyle}>
					{days.map((day, i) => (
						<View style={dayContainerStyle} key={day}>
							<Text style={[dayTextStyle]}>{day}</Text>
						</View>
					))}
				</View>
				<ScrollView
					style={{ flex: 1 }}
					showsVerticalScrollIndicator={false}
				>

					<View style={{
						flexDirection: 'row',
						flex: 1,
						justifyContent: 'flex-start',
					}}
					>
						<View style={{
							flex: 1 / 7,
							flexDirection: 'column',
							alignItems: 'stretch',
							justifyContent: 'center'
						}}
						>
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
							days.map((item, index) => (
								<View style={{
									flex: 1 / 7,
									flexDirection: 'column',
									alignItems: 'stretch',
									justifyContent: 'center'
								}}
								>
									{hours.map((hour, i) => (
										<View style={[timeRowStyle, { borderBottomWidth: i === 14 ? 1 : 0 }]} key={hour}>
											<View style={timeContainerStyle}>
												<View style={{ height: 50 }} />
											</View>
										</View>
									))}
								</View>))
						}
					</View>
					<TouchableWithoutFeedback onPress={() => this.props.selectCourse(null, null)}>
						<View
							style={{
								position: 'absolute',
								top: 0,
								bottom: 0,
								left: 0,
								right: 0,
							}}
						/>
					</TouchableWithoutFeedback>
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
		marginRight: 20,
		marginBottom: 55
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
		paddingTop: 16,
		paddingBottom: 16,
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


const mapStateToProps = state => ({
	selectedCourse: state.schedule.selectedCourse,
	courseCards: state.schedule.courseCards
})


const mapDispatchToProps = (dispatch, ownProps) => (
	{
		selectCourse: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE', selectedCourse, data })
		},
		updateCourseCard: (name, x, y, width, height) => {
			dispatch({ type: 'UPDATE_COURSE_CARD', name, x, y, width, height })
		},
		resetCourseCard: () => {
			dispatch({ type: 'RESET_COURSE_CARD' })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(ClassCalendar)
