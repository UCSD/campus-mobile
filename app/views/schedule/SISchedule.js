import React from 'react'
import { View, Text, TouchableWithoutFeedback } from 'react-native'
import Icon from 'react-native-vector-icons/Entypo'
import siSchedule from '../../util/siSchedule'
import css from '../../styles/css'

class SISchedule extends React.Component {
	constructor(props) {
		super()
		this.state = {
			selected: false
		}
	}

	renderSIsection() {
		const { siSession } = this.props
		let { selected } = this.state
		if (siSession && siSession.length > 0) {
			return (
				<View>
					<TouchableWithoutFeedback
						onPress={() => {
							selected = !selected
							this.setState({ selected })
						}}
					>
						<View style={css.fslv_si_text_container}>
							<Text style={css.fslv_si_session_text}>
								Supplemental Instruction
							</Text>
							{this.renderArrowIcon(selected)}
						</View>
					</TouchableWithoutFeedback>
					<View>
						{this.renderSILeaderText(selected, siSession)}
						{this.renderSIScheduleText(selected, siSession)}
					</View>
				</View>
			)
		} else {
			return null
		}
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
		}
		return (
			<Icon
				name="triangle-right"
				size={20}
				style={css.fslv_si_right_arrow_icon}
			/>
		)
	}

	renderSILeaderText() {
		const { siSession } = this.props
		const { selected } = this.state
		if (selected) {
			return (
				<View style={css.fslv_si_text_container}>
					<Text style={css.fslv_si_leader_text}>
						{'Leader: '}
					</Text>
					<Text>
						{siSession[0].si_leader}
					</Text>
				</View>
			)
		}
		return null
	}

	renderSIScheduleText() {
		const { siSession } = this.props
		const { selected } = this.state
		if (selected) {
			const scheduleArray = []
			siSession.forEach((siSesh) => {
				siSesh.days.forEach((day) => {
					const fullString = siSchedule.dayOfWeekInterpreter(day)
					const scheduleObj = (
						<View style={css.fslv_si_text_container}>
							<Text>
								{fullString} {siSesh.time}, {siSesh.building}, {siSesh.room}
							</Text>
						</View>
					)
					scheduleArray.push(scheduleObj)
				})
			})
			return scheduleArray
		}
	}

	render() {
		return this.renderSIsection()
	}
}
export default SISchedule