import React, { Component } from 'react'
import {
	View,
	Text,
	StyleSheet,
	TouchableHighlight,
	ActivityIndicator,
	Dimensions
} from 'react-native'
import FAIcon from 'react-native-vector-icons/FontAwesome'
import { connect } from 'react-redux'

import schedule from '../../../util/schedule'
import logger from '../../../util/logger'
import Card from '../../common/Card'
import LastUpdated from '../../common/LastUpdated'
import css from '../../../styles/css'
import COLOR from '../../../styles/ColorConstants'

const WINDOW_WIDTH = Dimensions.get('window').width

class DragableClassCard extends Component {
	onLayout = () => {
		this.container && this.container.measure(this.onMeasure)
	};

	onMeasure = (x, y, width, height, screenX, screenY) => {
		this.screenX = screenX
		this.screenY = screenY
		this.width   = width
		this.height  = height
		console.log(WINDOW_WIDTH, screenX, screenY, width, height)
		this.props.onRender(this.props.data, screenX % WINDOW_WIDTH, screenY, width, height)
	};

	// TODO: show class detail when card is tapped
	onPress = () => {
		this.props.onPress(this.props.data)
	};

	getClassStyle = () => ({
		...css.webreg_course_container,
		...(this.props.data.isBeingDragged ? {} : {}), // TODO: change style when the card is being dragged
	});


	render() {
		const {
			courseUnit,
			courseCode,
			courseTitle,
			sectionID,
			courseProf,
			courseSections,
		} = this.props.data

		return (
			<View
				style={css.webreg_course_container}
				ref={el => this.container = el}
				onLayout={this.onLayout}
			>
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
		<View style={type === 'LE' ? css.webreg_lecture_section_container : css.webreg_di_section_container}>
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

export default connect(null)(DragableClassCard)
