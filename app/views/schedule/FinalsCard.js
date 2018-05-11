import React, { Component } from 'react'
import { View, Text, FlatList } from 'react-native'
import { connect } from 'react-redux'

import Card from '../common/Card'
import LastUpdated from '../common/LastUpdated'
import logger from '../../util/logger'
import schedule from '../../util/schedule'
import css from '../../styles/css'

class FinalsCard extends Component {
	constructor(props) {
		super()
		this.state = { finalsData: this.getFinalsArray(props.scheduleData) }
	}

	componentDidMount() {
		logger.ga('Card Mounted: Finals')
	}

	getFinalsArray = (scheduleObject) => {
		const parsedScheduleData = schedule.getData(scheduleObject)
		const finalsData = schedule.getFinals(parsedScheduleData)
		const finalsArray = []
		Object.keys(finalsData).forEach((day) => {
			if (finalsData[day].length > 0) {
				finalsArray.push({
					day,
					data: finalsData[day]
				})
			}
		})
		return finalsArray
	}

	render() {
		if (!this.state.finalsData) {
			return null
		}

		// if (this.props.scheduleData.length > 0) {
		return (
			<Card id="finals" title="Finals">
				<FlatList
					data={this.state.finalsData}
					ItemSeparatorComponent={(<View style={css.finals_separator} />)}
					keyExtractor={(item, index) => (item.day)}
					renderItem={({ item: rowData }) => (
						<ScheduleDay id={rowData.day} data={rowData.data} />
					)}
				/>
				<LastUpdated
					lastUpdated={this.props.lastUpdated}
					error={
						(this.props.requestError === 'App update required.') ?
							('App update required.') :
							(null)
					}
					warning={
						(this.props.requestError) ?
							('We\'re having trouble updating right now.') :
							(null)
					}
				/>
			</Card>
		)
	}
}

const ScheduleDay = ({ id, data }) => (
	<View style={css.finals_card_content}>
		<Text style={css.finals_day_of_week}>{schedule.dayOfWeekInterpreter(id)}</Text>
		<DayList courseItems={data} />
	</View>
)

const DayList = ({ courseItems }) => (
	<FlatList
		data={courseItems}
		keyExtractor={(item, index) => (item.course_code + item.section)}
		renderItem={({ item: rowData }) => (
			<DayItem data={rowData} />
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
	lastUpdated: state.schedule.lastUpdated,
	requestError: state.requestErrors.GET_SCHEDULE
})

export default connect(mapStateToProps)(FinalsCard)
