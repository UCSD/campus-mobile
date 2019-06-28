import React from 'react'
import {
	View,
	Text,
	StyleSheet,
	ActivityIndicator,
	TouchableOpacity,
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'

import schedule from '../../../util/schedule'
import logger from '../../../util/logger'
import Card from '../../common/Card'
import LastUpdated from '../../common/LastUpdated'
import css from '../../../styles/css'
import COLOR from '../../../styles/ColorConstants'

const CourseListCard = ({ data }) => {
	const { subject_code, course_code, units, grade_option, course_title, section_data, enrollment_status } = data
	const
		courseUnit = units,
		courseCode = subject_code + course_code,
		courseTitle = course_title,
		sectionID = section_data[0].section,
		courseProf = section_data[0].instructor_name,
		courseSections = section_data,
		enrollmentStatus = enrollment_status

	return (
		<View style={[css.webreg_list_card_container, getBorderStyle(enrollmentStatus)]}>
			{/* Course Info */}
			<View style={css.webreg_list_card_info_container}>
				<View style={css.webreg_list_card_header_container}>
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
			</View>
			{/* Action buttons */}
			<View style={css.webreg_list_card_action_container}>
				<TouchableOpacity>
					<Icon name="cached" size={28} color={COLOR.PRIMARY} />
				</TouchableOpacity>
				<TouchableOpacity>
					<Icon name="delete" size={28} color={COLOR.PRIMARY} />
				</TouchableOpacity>
				<TouchableOpacity>
					<Icon name="add" size={28} color={COLOR.PRIMARY} />
				</TouchableOpacity>
			</View>
		</View>
	)
}
const getBorderStyle = (status) => {
	let borderStyle = { borderRadius: 10, borderWidth: 2, borderColor: COLOR.PRIMARY, borderStyle: 'solid' }
	switch (status) {
		// TODO
		case 'EN':
			break
		case 'WL':
			borderStyle = { ...borderStyle, borderStyle: 'dashed', borderWidth: 2 }
			break
		case 'PL':
			borderStyle = { ...borderStyle, borderColor: COLOR.DGREY }
			break
		default:
			break
	}
	return borderStyle
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

export default CourseListCard
