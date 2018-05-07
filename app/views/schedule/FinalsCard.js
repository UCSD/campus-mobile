import React from 'react'
import { View, Text, ListView } from 'react-native'
import { connect } from 'react-redux'

import Card from '../common/Card'
import logger from '../../util/logger'
import schedule from '../../util/schedule'
import css from '../../styles/css'

const dataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2
})

const FinalsCard = ({ scheduleData }) => {
	logger.ga('Card Mounted: Finals')

	if (!scheduleData) {
		return null
	}

	const parsedScheduleData = schedule.getData(scheduleData)
	const finalsData = schedule.getFinals(parsedScheduleData)

	// if (scheduleData.length > 0) {
	return (
		<Card id="finals" title="Finals">
			<ListView
				enableEmptySections={true}
				dataSource={dataSource.cloneWithRows(finalsData)}
				renderSeparator={(sectionID, rowID, adjacentRowHighlighted) => {
					if (finalsData[rowID].length > 0) {
						return (<View style={css.finals_separator} key={rowID} />)
					} else {
						return null
					}
				}}
				renderRow={(rowData, sectionID, rowID, highlightRow) => (
					<View>
						{finalsData[String(rowID)].length > 0 ? (
							<ScheduleDay id={rowID} data={rowData} />
						) : null}
					</View>
				)}
			/>
		</Card>
	)
}

const ScheduleDay = ({ id, data }) => (
	<View style={css.finals_card_content}>
		<Text style={css.finals_day_of_week}>{schedule.dayOfWeekInterpreter(id)}</Text>
		<DayList courseItems={data} />
	</View>
)

const DayList = ({ courseItems }) => (
	<ListView
		dataSource={dataSource.cloneWithRows(courseItems)}
		renderRow={(rowData, sectionID, rowID, highlightRow) => (
			<DayItem key={rowID} data={rowData} />
		)}
	/>
)

const DayItem = ({ data }) => (
	<View style={css.finals_day_container}>
		<Text style={css.finals_course_title}>
			{data.subject_code} {data.course_code}
		</Text>
		<Text style={css.finals_course_text} numberOfLines={1}>
			{data.course_title}
		</Text>
		<Text style={css.finals_course_text}>
			{data.time_string + '\n'}
			{data.building + ' ' + data.room}
		</Text>
	</View>
)

const mapStateToProps = state => ({
	scheduleData: state.schedule.data,
})

const ActualFinalsCard = connect(mapStateToProps)(FinalsCard)

export default ActualFinalsCard
