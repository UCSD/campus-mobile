import React from 'react'
import {
	View,
	Text,
	StyleSheet,
	TouchableHighlight,
	ActivityIndicator,
	TouchableOpacity,
	Alert
} from 'react-native'
import { connect } from 'react-redux'
import FAIcon from 'react-native-vector-icons/FontAwesome'

import schedule from '../../../util/schedule'
import logger from '../../../util/logger'
import Card from '../../common/Card'
import LastUpdated from '../../common/LastUpdated'
import css from '../../../styles/css'
import COLOR from '../../../styles/ColorConstants'

class CalendarModalCard extends React.Component {
	constructor(props) {
		super(props)
		this.state = { gradeOption: this.props.data.grade_option }
		this.changeGradeOption = this.changeGradeOption.bind(this)
		this.dropCourse = this.dropCourse.bind(this)
	}

	changeGradeOption() {
		Alert.alert(
		  'Change Grade Option',
		  'This action will be unavailble after week 4.',
		  [
		    {
		      text: 'Cancel',
		      style: 'cancel',
		    },
		    {
					text: 'OK',
					onPress: () => {
						// TODO: change to api call via saga
						if (this.state.gradeOption === 'L') {
							this.setState({ gradeOption: 'P' })
						} else {
							this.setState({ gradeOption: 'L' })
						}
					}
				},
		  ],
		  { cancelable: false },
		)
	}

	dropCourse() {
		Alert.alert(
		  'Drop Course',
		  'This action cannot be undone.',
		  [
		    {
		      text: 'Cancel',
		      style: 'cancel',
		    },
		    {
					text: 'Drop',
					style: 'destructive',
					onPress: () => {
						// TODO: change to api call via saga
						this.props.selectCourse(null, null)
					}
				},
		  ],
		  { cancelable: false },
		)
	}

	renderGradeOption() {
		const { gradeOption } = this.state

		const color_1 = gradeOption === 'L' ? COLOR.WHITE : COLOR.PRIMARY
		const color_2 = gradeOption === 'L' ? COLOR.PRIMARY : COLOR.WHITE

		return (
			<View style={css.webreg_common_grade_option_button_container}>
				<View style={css.webreg_common_grade_option_button}>
					<TouchableOpacity
						style={[css.webreg_common_grade_option_button_left, { backgroundColor: color_1 }]}
						onPress={this.changeGradeOption}
					>
						<Text style={[css.webreg_common_action_button_text, { color: color_2 }]}>P/NP</Text>
					</TouchableOpacity>
					<TouchableOpacity
						style={[css.webreg_common_grade_option_button_right, { backgroundColor: color_2 }]}
					>
						<Text style={[css.webreg_common_action_button_text, { color: color_1 }]}>Letter</Text>
					</TouchableOpacity>
				</View>
			</View>
		)
	}

	renderEnrollmentAction() {
		return (
			<TouchableOpacity
				style={css.webreg_common_enrollment_action_button}
				onPress={this.dropCourse}
			>
				<Text style={[css.webreg_common_action_button_text, { color: COLOR.WHITE }]}>Drop course</Text>
			</TouchableOpacity>
		)
	}

	render() {
		const { data } = this.props
		const { subject_code, course_code, units, course_title, section_data } = data
		const
			courseUnit      = units,
			courseCode      = subject_code + course_code,
			courseTitle     = course_title,
			sectionID       = section_data[0].section,
			courseProf      = section_data[0].instructor_name,
			courseSections  = section_data

		return (
			<View style={css.webreg_modal_card_container}>
				<View style={css.webreg_modal_card_header_container}>
					<View style={css.webreg_common_unit_container}>
						<View style={css.webreg_common_unit_bg}>
							<Text style={css.webreg_common_unit_text} allowFontScaling={false} >
								{courseUnit}
							</Text>
						</View>
					</View>
					<View style={css.webreg_common_name_container}>
						<Text style={css.webreg_common_code}>{courseCode}</Text>
						<Text style={css.webreg_common_title}>{courseTitle}</Text>
					</View>
				</View>
				{/* Section Header */}
				<View style={css.webreg_section_header_container}>
					<View style={css.webreg_section_id_container} >
						<Text style={css.webreg_section_id_label}>Section ID</Text>
						<Text style={css.webreg_section_id_id}>{sectionID}</Text>
					</View>
					<View style={css.webreg_section_prof_container} >
						<Text style={css.webreg_section_prof_text} numberOfLines={1} >
							{courseProf}
						</Text>
					</View>
				</View>
				{renderSchedule('LE', courseSections)}
				{renderSchedule('DI', courseSections)}
				{renderSchedule('FI', courseSections)}
				<View style={css.webreg_common_action_button_container}>
					{this.renderGradeOption()}
					{this.renderEnrollmentAction()}
				</View>
			</View>
		)
	}
}


const renderSchedule = (type, courseSections) => {
	let section,
		timeString,
		place,
		finalDate
	const daysOfWeek = {
			MO: false,
			TU: false,
			WE: false,
			TH: false,
			FR: false,
		},
		days = ['MO', 'TU', 'WE', 'TH', 'FR'],
		daysAbbr = ['M', 'T', 'W', 'T', 'F']

	courseSections.map((item, idx) => {
		if (item.special_mtg_code === type) {
			finalDate = item.date
			timeString = item.time
			place = item.building + ' ' + item.room
		} else if (item.meeting_type === ((type === 'LE' || type === 'FI') ? 'Lecture' : 'Discussion') && item.special_mtg_code === '') {
			section = item.section_code
			daysOfWeek[item.days] = true
			timeString = item.time
			place = item.building + ' ' + item.room
		}
		return null
	})

	if (type === 'FI') {
		return (
			<View style={css.webreg_section_container}>
				<View style={{ flexDirection: 'row', justifyContent: 'space-between', flex: 1 }}>
					<Text style={{ color: COLOR.DGREY, flex: 0.18, fontSize: 12 }}>FINAL</Text>
					<Text style={{ flex: 0.27, fontSize: 12, color: COLOR.PRIMARY, flexWrap: 'wrap', flexDirection: 'row' }}>{finalDate}</Text>
					<Text style={{ flex: 0.3, fontSize: 12, textAlign: 'center' }}>{timeString}</Text>
					<Text style={{ flex: 0.25, fontSize: 12, textAlign: 'center' }}>{place}</Text>
				</View>
			</View>
		)
	}
	return (
		<View style={css.webreg_section_container}>

			<View style={{ flexDirection: 'row', justifyContent: 'space-between', flex: 1 }}>
				<Text style={{ color: COLOR.DGREY, flex: 0.09, fontSize: 12 }}>{section + ' '}</Text>
				<Text style={{ color: 'black', flex: 0.09, fontSize: 12 }}>{type}</Text>
				<View style={{ flex: 0.27, flexWrap: 'wrap', flexDirection: 'row' }}>
					{
						days.map((item, idx) => {
							if (daysOfWeek[item]) {
								return <Text style={{ color: COLOR.PRIMARY, paddingRight: idx === days.length ? 0 : 3, fontSize: 12 }}>{daysAbbr[idx]}</Text>
							} else {
								return <Text style={{ color: COLOR.MGREY, paddingRight: idx === days.length ? 0 : 3, fontSize: 12 }}>{daysAbbr[idx]}</Text>
							}
						})
					}
				</View>
				<Text style={{ flex: 0.3, fontSize: 12, textAlign: 'center' }}>{timeString}</Text>
				<Text style={{ flex: 0.25, fontSize: 12, textAlign: 'center' }}>{place}</Text>
			</View>
		</View>
	)
}

const padString = (direction, str, len) => {
	if (str === undefined) return
	if (direction === 'end') return str.padEnd(len, ' ')
	else return str.padStart(len, ' ')
}

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		selectCourse: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE', selectedCourse, data })
		},
	}
)

export default connect(null, mapDispatchToProps)(CalendarModalCard)
