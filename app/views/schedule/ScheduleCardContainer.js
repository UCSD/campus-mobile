import React from 'react'
import { connect } from 'react-redux'
import moment from 'moment'
import FullScheduleButton from './FullScheduleButton'
import ScheduleCard from './ScheduleCard'
import schedule from '../../util/schedule'

let defaultSelectedClass = null

const getUpcomingClasses = (scheduleData) => {
	if (!scheduleData) return []

	const parsedScheduleData = schedule.getData(scheduleData)
	const classesData = schedule.getClasses(parsedScheduleData)
	const date = moment()
	const dayOfTheWeek = date.day()
	const currTime = moment(date.format('HH:mm a'), ['HH:mm A']).format('HHmm')
	const MAX_RESULTS = 4

	/** result:Array - Classes with a specific day of the week **/
	const result = []
	/** times:Array - An array of parsed class end times **/
	const times = []
	/** otherResults:Array - Classes without a specific day of the week **/
	const otherResults = []

	/** Add classes scheduled to take place today to the `result` array **/
	switch (dayOfTheWeek) {
		case 0:
			result.push(...classesData.SU)
			break
		case 1:
			result.push(...classesData.MO)
			break
		case 2:
			result.push(...classesData.TU)
			break
		case 3:
			result.push(...classesData.WE)
			break
		case 4:
			result.push(...classesData.TH)
			break
		case 5:
			result.push(...classesData.FR)
			break
		case 6:
			result.push(...classesData.SA)
			break
	}

	/** Loop classes scheduled to take place today **/
	for (let i = 0; i < result.length; i++) {
		if (result[i].time_string) {
			/** If a class has a set time, parse it and push it to the `times` array **/
			const arr = result[i].time_string.split(' – ')
			const endTime = arr[1].replace(/\./gi, '')
			const newEndTime = moment(endTime, ['h:mm A']).format('HHmm')
			times.push(newEndTime)
		} else {
			/** If a class has no set time, push it to the `otherResults` array **/
			otherResults.push(result[i])
		}
	}

	let i = 0
	while (times[i] < currTime) {
		if (result.length > 4) {
			result.shift()
			times.shift()
		}
		i++
	}

	for (let j = 0; j < times.length; j++) {
		if (times[j] > currTime) {
			defaultSelectedClass = j
			break
		}
	}

	if (defaultSelectedClass == null) {
		defaultSelectedClass = 0
		otherResults.lenth = MAX_RESULTS
		otherResults.push(...classesData.OTHER)
		return otherResults
	} else {
		return result
	}
}

class ScheduleCardContainer extends React.Component {
	constructor(props) {
		super(props)

		this.state = {
			upcoming4Courses: getUpcomingClasses(props.scheduleData),
			activeCourse: null
		}
		this.onClickCourse = this.onClickCourse.bind(this)
	}

	componentWillMount() {
		this.setState({ activeCourse: defaultSelectedClass })
	}

	/** TODO: Review ScheduleCardContainer::componentWillReceiveProps **/
	componentWillReceiveProps(nextProps) {
		if ((nextProps.scheduleData) || (this.props.scheduleData && !nextProps.scheduleData)) {
			this.setState((state, props) => ({
				...state,
				upcoming4Courses: getUpcomingClasses(props.scheduleData)
			}))
		}
	}

	onClickCourse(newActiveCourse) {
		this.setState(prevState => ({
			...prevState,
			activeCourse: newActiveCourse,
		}))
	}

	render() {
		return (
			<ScheduleCard
				onClickCourse={this.onClickCourse}
				waitingData={this.props.requestStatus}
				lastUpdated={this.props.lastUpdated}
				error={this.props.requestError}
				coursesToShow={this.state.upcoming4Courses}
				activeCourse={this.state.activeCourse}
				currentTerm={this.props.currentTerm}
				actionButton={<FullScheduleButton />}
			/>
		)
	}
}

const mapStateToProps = state => ({
	scheduleData: state.schedule.data,
	lastUpdated: state.schedule.lastUpdated,
	currentTerm: state.schedule.currentTerm,
	requestStatus: state.requestStatuses.GET_SCHEDULE,
	requestError: state.requestErrors.GET_SCHEDULE
})

export default connect(mapStateToProps)(ScheduleCardContainer)
