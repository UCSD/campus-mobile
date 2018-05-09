import React from 'react'
import { SectionList, View, Text } from 'react-native'
import { connect } from 'react-redux'

import logger from '../../util/logger'
import schedule from '../../util/schedule'
import css from '../../styles/css'

class FullSchedule extends React.Component {
	constructor(props) {
		super()
		this.state = { scheduleSections: this.getScheduleArray(props.fullScheduleData) }
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

	renderItem = ({ item, index, section }) => (<IndividualClass data={item} />)

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
			/>
		)
	}
}

const IndividualClass = ({ data }) => (
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
		<Text style={css.fslv_course_text}>
			{data.meeting_type} {data.time_string + '\n'}
			{data.instructor_name + '\n'}
			{data.building + data.room}
		</Text>
	</View>
)

function mapStateToProps(state) {
	return { fullScheduleData: state.schedule.data }
}

const FullScheduleListView = connect(mapStateToProps)(FullSchedule)

export default FullScheduleListView
