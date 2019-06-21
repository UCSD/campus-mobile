import { Text, View, ScrollView, Dimensions, Button, TouchableWithoutFeedback } from 'react-native'
import React from 'react'
import { connect } from 'react-redux'
import Icon from 'react-native-vector-icons/FontAwesome'

import auth from '../../../util/auth'
import CourseListMockData from './mockData/CourseListMockData.json'
import { getFinalIndex, getCourseList } from '../../../util/schedule'
import css from '../../../styles/css'
import CourseCard from './CourseCard'

const { width, height } = Dimensions.get('window')
const CARD_WIDTH = (width - 70) / 7
const CARD_HEIGHT = 50
const COLOR_LIST = ['#ffdfba', '#ffffba', '#baffc9', '#bae1ff', 'rgb(193, 224, 252)']
const MOCK_DATE = ['6/8/19', '6/10/19', '6/11/19', '6/12/19', '6/13/19', '6/14/19', '6/15/19']
const getBottomMargin = (device) => {
	switch (device) {
		case 1:
			return 55
		case 2:
			return 72
		default:
			return 0
	}
}

class FinalCalendar extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			courses: CourseListMockData.data,
			sample: CourseListMockData.data[0],
			courseList: getCourseList(CourseListMockData.data, true, CARD_WIDTH, CARD_HEIGHT)
		}
	}


	renderCourseCard() {
		const res = []

		Object.keys(this.state.courseList).map((item, i) => {
			this.state.courseList[item].data.map((course, index) => {
				const { color = 0, name, location, display, type, selected, x, y, height, width, status = 'enrolled' } = course

				const onLayout = (event) => {
					const { x, y, width, height } = event.nativeEvent.layout
					console.log('onLayout,', { name, x, y, width, height })
					this.props.updateCourseCard(name, x, y, width, height)
				}

				if (this.props.selectedCourse && this.props.selectedCourse === name) {
					res.push(<CourseCard
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
					console.log({ index: i, left: x + width, top: y })

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
									top: y - (height / 15),
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
					res.push(<CourseCard
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
		console.log(this.props.selectedCourse, this.state.courseList)

		const { courses, sample } = this.state
		const days = ['Sat', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
		const hours = ['8 am', '9 am', '10 am', '11 am', '12 pm', '1 pm', '2 pm', '3 pm', '4 pm', '5 pm', '6 pm', '7 pm', '8 pm', '9 pm']
		const { device } = this.props

		const {
			webreg_final_calendar_card,
			webreg_final_calendar_daysContainer,
			webreg_final_calendar_dayContainer,
			webreg_final_calendar_dayText,
			webreg_final_calendar_timeText,
			webreg_final_calendar_timeRow,
			webreg_final_calendar_timeContainer
		} = css

		let offset = 0

		switch (device) {
			case 1:
				offset = 60
				break
			case 2:
				offset = 77
				break
			case 0:
			default:
				offset = 0
				break
		}

		return (
			<View style={[webreg_final_calendar_card, { marginBottom: getBottomMargin(this.props.device) }]}>
				<View style={webreg_final_calendar_daysContainer}>
					{days.map((day, i) => (
						<View style={webreg_final_calendar_dayContainer} key={day}>
							<Text style={[webreg_final_calendar_dayText, { paddingBottom: 0 }]}>{day}</Text>
							<Text style={[webreg_final_calendar_dayText, { paddingTop: 0 }]}>{MOCK_DATE[i]}</Text>
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
								<View style={[webreg_final_calendar_timeRow, { borderBottomWidth: i === 13 ? 1 : 0 }]} key={hour}>
									<View style={webreg_final_calendar_timeContainer}>
										<Text style={webreg_final_calendar_timeText}>
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
										<View style={[webreg_final_calendar_timeRow, { borderBottomWidth: i === 13 ? 1 : 0 }]} key={hour}>
											<View style={webreg_final_calendar_timeContainer}>
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
					{ this.renderCourseCard() }
				</ScrollView>
			</View>
		)
	}
}

const mapStateToProps = state => ({
	selectedCourse: state.schedule.selectedCourseFinal,
	courseCards: state.schedule.finalCards
})

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		selectCourse: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE_FINAL', selectedCourse, data })
		},
		updateCourseCard: (name, x, y, width, height) => {
			dispatch({ type: 'UPDATE_FINAL_CARD', name, x, y, width, height })
		},
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(FinalCalendar)
