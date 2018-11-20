import React from 'react'
import { connect } from 'react-redux'
import moment from 'moment'
import FullScheduleButton from './FullScheduleButton'
import ScheduleCard from './ScheduleCard'
import logger from '../../util/logger'
import schedule from '../../util/schedule'

const processData = (scheduleData) => {
	if (!scheduleData) return []

	const parsedScheduleData = schedule.getData(scheduleData)
	const classesData = schedule.getClasses(parsedScheduleData)

	const date = moment()
	const dayOfTheWeek = date.day()
	const currTime = moment(date.format('HH:mm a'), ['HH:mm A']).format('HHmm')

	const result = []

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
		default:
			result.push(...classesData.OTHER)
			break
	}

	const times = []
	for (let i = 0; i < result.length; i++) {
		const arr = result[i].time_string.split(' – ')
		const endTime = arr[1].replace(/\./gi, '')
		const newEndTime = moment(endTime, ['h:mm A']).format('HHmm')
		times.push(newEndTime)
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
			selectedClass = j
			break
		}
	}

	return result
}

let selectedClass = 0

class ScheduleCardContainer extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			upcoming4Courses: processData(props.scheduleData),
			activeCourse: 0
		}
		this.onClickCourse = this.onClickCourse.bind(this)
	}

	componentWillMount() {
		logger.ga('Card Mounted: Classes')
		this.setState({ activeCourse: selectedClass })
	}
	componentWillReceiveProps(nextProps) {
		if (nextProps.scheduleData ||
			(this.props.scheduleData && !nextProps.scheduleData)) {
			this.setState((state, props) => ({
				...state,
				upcoming4Courses: processData(props.scheduleData)
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
