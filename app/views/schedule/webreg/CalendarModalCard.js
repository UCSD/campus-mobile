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
		if (this.state.gradeOption === 'L') {
			return (
				<View style={css.webreg_course_info_container}>
					<View style={{ flex: 0.5, flexDirection: 'row', justifyContent: 'flex-start', marginTop: 10, marginRight: 15 }}>
						<TouchableOpacity
							style={{
								borderBottomLeftRadius: 6,
								borderTopLeftRadius: 6,
								paddingTop: 8,
								paddingBottom: 8,
								flex: 0.5,
								backgroundColor: 'rgb(255, 255, 255)',
								borderWidth: 1,
								borderColor: 'rgb(25, 66, 96)'
							}}
							onPress={this.changeGradeOption}
						>
							<Text style={{ textAlign: 'center', fontSize: 16, color: 'rgb(25, 66, 96)' }}>PNP</Text>
						</TouchableOpacity>
						<TouchableOpacity
							style={{
								borderBottomRightRadius: 6,
								borderTopRightRadius: 6,
								paddingTop: 8,
								paddingBottom: 8,
								flex: 0.5,
								backgroundColor: 'rgb(25, 66, 96)',
								borderWidth: 1,
								borderColor: 'rgb(25, 66, 96)'
							}}
						>
							<Text style={{ textAlign: 'center', fontSize: 16, color: 'white' }}>Letter</Text>
						</TouchableOpacity>
					</View>
					<TouchableOpacity
						style={{ borderRadius: 6, marginTop: 10, marginLeft: 15, paddingTop: 8, paddingBottom: 8, flex: 0.5, backgroundColor: 'rgb(25, 66, 96)' }}
						onPress={this.dropCourse}
					>
						<Text style={{ textAlign: 'center', fontSize: 16, color: 'white' }}>Drop course</Text>
					</TouchableOpacity>
				</View>
			)
		} else {
			return (
				<View style={css.webreg_course_info_container}>
					<View style={{ flex: 0.5, flexDirection: 'row', justifyContent: 'flex-start', marginTop: 10, marginRight: 15 }}>
						<TouchableOpacity
							style={{
								borderBottomLeftRadius: 6,
								borderTopLeftRadius: 6,
								paddingTop: 8,
								paddingBottom: 8,
								flex: 0.5,
								backgroundColor: 'rgb(25, 66, 96)',
								borderWidth: 1,
								borderColor: 'rgb(25, 66, 96)'
							}}
						>
							<Text style={{ textAlign: 'center', fontSize: 16, color: 'white' }}>PNP</Text>
						</TouchableOpacity>
						<TouchableOpacity
							style={{
								borderBottomRightRadius: 6,
								borderTopRightRadius: 6,
								paddingTop: 8,
								paddingBottom: 8,
								flex: 0.5,
								backgroundColor: 'rgb(255, 255, 255)',
								borderWidth: 1,
								borderColor: 'rgb(25, 66, 96)'
							}}
							onPress={this.changeGradeOption}
						>
							<Text style={{ textAlign: 'center', fontSize: 16, color: 'rgb(25, 66, 96)' }}>Letter</Text>
						</TouchableOpacity>
					</View>
					<TouchableOpacity style={{ borderRadius: 6, marginTop: 10, marginLeft: 15, paddingTop: 8, paddingBottom: 8, flex: 0.5, backgroundColor: 'rgb(25, 66, 96)' }}><Text style={{ textAlign: 'center', fontSize: 16, color: 'white' }}>Drop course</Text></TouchableOpacity>
				</View>
			)
		}
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
			<View style={css.webreg_course_container}>
				<View style={css.webreg_course_info_container}>
					<View style={css.webreg_course_unit_container}>
						<View style={css.webreg_course_unit_bg}>
							<Text style={css.webreg_course_unit_text} allowFontScaling={false} >
								{courseUnit}
							</Text>
						</View>
					</View>
					<View style={css.webreg_course_name_container}>
						<Text style={css.webreg_course_code}>{courseCode}</Text>
						<Text style={css.webreg_course_title}>{courseTitle}</Text>
					</View>
				</View>
				<View style={css.webreg_section_prof_container}>
					<View style={css.webreg_section_container} >
						<Text style={css.webreg_section_id}>Section ID</Text>
						<Text>{sectionID}</Text>
					</View>
					<View style={css.webreg_prof_container} >
						<Text style={css.webreg_course_prof} numberOfLines={1} >
							{courseProf}
						</Text>
					</View>
				</View>
				{renderSchedule('LE', courseSections)}
				{renderSchedule('DI', courseSections)}
				{this.renderGradeOption()}
			</View>
		)
	}
}


const renderSchedule = (type, courseSections) => {
	let section,
		timeString,
		place
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
		if (item.meeting_type === (type === 'LE' ? 'Lecture' : 'Discussion')) {
			section               = item.section_code
			daysOfWeek[item.days] = true
			timeString            = item.time
			place                 = item.building
		}
		return null
	})

	return (
		<View style={[type === 'LE' ? css.webreg_lecture_section_container : css.webreg_di_section_container, { alignSelf: 'center' }]}>
			<Text style={{ color: 'rgb(159, 159, 159)', flex: 0.12 }}>{section}</Text>
			<View style={{ flex: 0.88, flexDirection: 'row', justifyContent: 'space-between' }}>
				<Text style={{ flex: 0.2, color: type === 'LE' ? 'rgb(159, 159, 159)' : 'black' }}>{type}</Text>
				<View style={{ flex: 0.5, flexWrap: 'wrap', flexDirection: 'row' }}>
					{
						days.map((item, idx) => {
							if (daysOfWeek[item]) {
								return <Text style={{ color: 'rgb(84, 129, 176)', paddingRight: idx === days.length ? 0 : 3 }}>{daysAbbr[idx]}</Text>
							} else {
								return <Text style={{ color: 'rgb(222, 222, 222)',  paddingRight: idx === days.length ? 0 : 3 }}>{daysAbbr[idx]}</Text>
							}
						})
					}
				</View>
				<Text style={{ flex: 0.5 }}>{timeString}</Text>
				<Text style={{ flex: 0.3, flexDirection: 'row', justifyContent: 'flex-end', textAlign: 'right' }}>{place}</Text>
			</View>
		</View>)
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
