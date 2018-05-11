import React from 'react'
import { connect } from 'react-redux'

import FullScheduleButton from './FullScheduleButton'
import ScheduleCard from './ScheduleCard'
import logger from '../../util/logger'
import schedule from '../../util/schedule'

const processData = (scheduleData) => {
	if (!scheduleData) return []

	const parsedScheduleData = schedule.getData(scheduleData)
	const classesData = schedule.getClasses(parsedScheduleData)

	let result = []
	result.push(...classesData.MO)
	result.push(...classesData.TU)
	result.push(...classesData.WE)
	result.push(...classesData.TH)
	result.push(...classesData.FR)
	result.push(...classesData.SA)
	result.push(...classesData.SU)
	result = result.slice(0, 4)
	return result
}

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
	}
	componentWillReceiveProps(nextProps) {
		if (nextProps.scheduleData ||
			(this.props.scheduleData && !nextProps.scheduleData)) {
			// console.warn('receive new prop')
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
