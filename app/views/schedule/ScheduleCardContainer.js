import React from 'react'
import { connect } from 'react-redux'

import FullScheduleButton from './FullScheduleButton'
import ScheduleCard from './ScheduleCard'
import logger from '../../util/logger'
import schedule from '../../util/schedule'

/**
 * Container component for [ScheduleCard]{@link ScheduleCard}
 **/
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
		if (nextProps.scheduleData) {
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
		this.forceUpdate()
	}
	render() {
		return (
			<ScheduleCard
				onClickCourse={this.onClickCourse}
				// waitingData={this.state.courseDataReceived}
				coursesToShow={this.state.upcoming4Courses}
				activeCourse={this.state.activeCourse}
				actionButton={<FullScheduleButton />}
			/>
		)
	}
}

const mapStateToProps = state => ({
	scheduleData: state.schedule.data
})

export default connect(mapStateToProps)(ScheduleCardContainer)
