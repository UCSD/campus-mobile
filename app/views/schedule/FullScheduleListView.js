import React from 'react'
import { ListView, View, Text } from 'react-native'
import { connect } from 'react-redux'

import logger from '../../util/logger'
import schedule from '../../util/schedule'
import css from '../../styles/css'

const rowHasChanged = (r1, r2) => r1.id !== r2.id
const sectionHeaderHasChanged = (s1, s2) => s1 !== s2
const ds = new ListView.DataSource({ rowHasChanged, sectionHeaderHasChanged })

class FullSchedule extends React.Component {
	constructor(props) {
		super()
		this.state = {
			dataSource: ds.cloneWithRowsAndSections(schedule.getData(props.fullScheduleData))
		}
	}

	componentDidMount() {
		logger.ga('Card Mounted: Full Schedule')
	}

	renderRow = (rowData, sectionId) => (
		<IndividualClass key={sectionId} data={rowData} />
	)

	renderSectionHeader = (sectionRows, sectionId) => {
		const day = schedule.dayOfWeekInterpreter(sectionId)
		if (day === 'Saturday' || day === 'Sunday') {
			return null
		}
		return (
			<View style={css.fslv_header_wrapper}>
				<Text style={css.fslv_header_text}>
					{day}
				</Text>
			</View>
		)
	}

	render() {
		return (
			// TODO: CONVERT TO SECTIONLIST
			<ListView
				style={css.fslv_container}
				dataSource={this.state.dataSource}
				renderRow={this.renderRow}
				renderSectionHeader={this.renderSectionHeader}
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
