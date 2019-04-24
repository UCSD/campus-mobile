import React from 'react'
import { View, Text } from 'react-native'
import Icon from 'react-native-vector-icons/Entypo'
import siSchedule from '../../util/siSchedule'
import css from '../../styles/css'
import Touchable from '../common/Touchable'

class SISchedule extends React.Component {
	constructor(props) {
		super()
		this.state = {
			selected: false
		}
	}

	renderSIsection() {
		let { selected } = this.state
		return (
			<View style={css.fslv_si_container}>
				<Touchable
					onPress={() => {
						selected = !selected
						this.setState({ selected })
					}}
				>
					<View style={css.fslv_si_session}>
						<Text style={css.fslv_si_session_text}>
							Supplemental Instruction
						</Text>
						{this.renderArrowIcon(selected)}
					</View>
				</Touchable>
				<View>
					{this.renderAllText()}
				</View>
			</View>
		)
	}

	renderArrowIcon() {
		const { selected } = this.state
		if (selected) {
			return (
				<Icon
					name="triangle-down"
					size={20}
					style={css.fslv_si_down_arrow_icon}
				/>
			)
		} else {
			return (
				<Icon
					name="triangle-right"
					size={20}
					style={css.fslv_si_right_arrow_icon}
				/>
			)
		}
	}

	renderAllText() {
		const { siSessions, instructor_name, course_title } = this.props
		const { selected } = this.state
		const siSessionObj = siSessions[course_title][instructor_name]
		const text = []
		if (selected) {
			Object.keys(siSessionObj).forEach((leader) => {
				const leaderText = renderSILeaderText(leader)
				const scheduleText = renderSIScheduleText(siSessionObj, leader)
				text.push(leaderText)
				text.push(scheduleText)
			})
		}
		return text
	}

	render() {
		return this.renderSIsection()
	}
}

const renderSILeaderText = SILeaderName => (
	<View style={css.fslv_si_text_container}>
		<Text><Text style={css.bold}>Leader: </Text>{SILeaderName}</Text>
	</View>
)

const renderSIScheduleText = (siSessions, leader) =>  {
	const scheduleObj = {}
	siSessions[leader].forEach((siSession) => {
		siSession.days.forEach((day) => {
			const fullString = siSchedule.dayOfWeekInterpreter(day)
			const time = siSchedule.convertTime(siSession.time)
			const scheduleText = (
				<View style={css.fslv_si_text_container}>
					<Text>
						{fullString} {time}, {siSession.building}, {siSession.room}
					</Text>
				</View>
			)
			scheduleObj[fullString] = scheduleText
		})
	})
	const scheduleArray = siSchedule.reorderWeekDays(scheduleObj)
	return scheduleArray
}

export default SISchedule
