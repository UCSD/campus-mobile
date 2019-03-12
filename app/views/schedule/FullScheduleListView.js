import React from 'react'
import { SectionList, View, Text } from 'react-native'
import { connect } from 'react-redux'

import logger from '../../util/logger'
import schedule from '../../util/schedule'
import css from '../../styles/css'
import SISchedule from './SISchedule'

class FullSchedule extends React.Component {
	constructor(props) {
		super()
		this.state = {
			scheduleSections: this.getScheduleArray(props.fullScheduleData),
		}
	}

	componentDidMount() {
		logger.ga('View Loaded: Classes (View All)')
	}

	getScheduleArray = (scheduleObject) => {
		const scheduleData = schedule.getData(scheduleObject)
		const scheduleArray = []
		Object.keys(scheduleData).forEach((day) => {
			if (Array.isArray(scheduleData[day]) && scheduleData[day].length > 0) {
				scheduleArray.push({
					day,
					data: scheduleData[day]
				})
			}
		})
		return scheduleArray
	}

	getMatchingSISessions = (classObject) => {
		const { siSessions } = this.props
		let session = null
		siSessions.forEach((siSession) => {
			if (siSession.course === (classObject.subject_code + ' ' + classObject.course_code)) {
				session = siSession
			}
		})
		return session
	}

	keyExtractor = (item, index) => (item.course_code + item.section)

	renderSectionHeader = ({ section: { day } }) => {
		const dayTitle = schedule.dayOfWeekInterpreter(day)
		return (
			<View style={css.fslv_header_wrapper}>
				<Text style={css.fslv_header_text}>
					{dayTitle}
				</Text>
			</View>
		)
	}

	renderItem = ({ item, index, section }) => {
		// Only show classes without a special meeting code (i.e. 'FI', 'PB', etc)
		if (!item.special_mtg_code) {
			const siSession = this.getMatchingSISessions(item)
			return (<IndividualClass data={item} props={this.props} siSession={siSession} />)
		} else {
			return null
		}
	}

	render() {
		return (
			<SectionList
				style={css.fslv_container}
				sections={this.state.scheduleSections}
				renderItem={this.renderItem}
				renderSectionHeader={this.renderSectionHeader}
				keyExtractor={this.keyExtractor}
				stickySectionHeadersEnabled={true}
				enableEmptySections={true}
				ItemSeparatorComponent={renderSeparator}
			/>
		)
	}
}

const renderSeparator = () => (
	<View style={css.fslv_flat_list_separator} />
)

const IndividualClass = ({ data, props, siSession }) => {
	let classTime,
		classLocation,
		classEval

	if (data.time_string) {
		classTime = data.time_string + '\n'
	} else {
		classTime = '\n'
	}

	if (data.building) {
		classLocation = data.building + ' ' +
			data.room + '\n'
	} else {
		classLocation = 'No Location Associated\n'
	}

	switch (data.grade_option) {
		case 'L': {
			classEval = 'Letter Grade'
			break
		}
		case 'P': {
			classEval = 'Pass/No Pass'
			break
		}
		case 'S': {
			classEval = 'Sat/Unsat'
			break
		}
		default: {
			classEval = ''
		}
	}
	return (
		<View style={css.fslv_row}>
			<Text style={css.fslv_course_code}>
				{data.subject_code} {data.course_code}
			</Text>
			<Text
				style={css.fslv_course_title}
				numberOfLines={1}
			>
				{data.course_title}
			</Text>
			<Text
				style={css.fslv_course_instructor}
				numberOfLines={1}
			>
				{data.instructor_name}
			</Text>
			<Text style={css.fslv_course_text}>
				{data.meeting_type} {classTime}
				{classLocation}
				{classEval}
				{'\n'}
			</Text>
			<SISchedule siSession={siSession} />
		</View>
	)
}

function mapStateToProps(state) {
	return {
		fullScheduleData: state.schedule.data,
		siSessions: state.supplementalInstruction.sessions
	}
}

const FullScheduleListView = connect(mapStateToProps)(FullSchedule)

export default FullScheduleListView
