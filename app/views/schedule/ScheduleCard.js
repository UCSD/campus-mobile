import React from 'react'
import PropTypes from 'prop-types'
import {
	View,
	Text,
	StyleSheet,
	TouchableHighlight,
	ActivityIndicator
} from 'react-native'
import FAIcon from 'react-native-vector-icons/FontAwesome'
import SimpleIcon from 'react-native-vector-icons/SimpleLineIcons'

import schedule from '../../util/schedule'
import Card from '../common/Card'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

const ScheduleCard = ({ coursesToShow, actionButton, activeCourse, onClickCourse }) => (
	<Card id="schedule" title="Classes">
		{coursesToShow.length ? (
			<View style={css.cc_sc_scheduleCard}>
				<View style={css.cc_container}>
					<View style={css.cc_leftHalf}>
						<View style={css.cc_leftHalf_upper}>
							<View style={css.cc_leftHalf_upper_timeText}>
								<ScheduleText style={css.cc_leftHalf_upper_timeText_firstSection}>
									{/* Today 9 */}
									{schedule.dayOfWeekInterpreter(coursesToShow[activeCourse].day_code)}
								</ScheduleText>
								<ScheduleText style={css.cc_leftHalf_upper_timeText_secondSection}>
									{/* AM */}
								</ScheduleText>
							</View>
							<View style={css.cc_leftHalf_upper_classText}>
								<ScheduleText style={css.cc_leftHalf_upper_classText_firstSection}>
									{coursesToShow[activeCourse].subject_code + ' '
										+ coursesToShow[activeCourse].course_code}
								</ScheduleText>
								<ScheduleText style={css.cc_leftHalf_upper_classText_secondSection}>
									{coursesToShow[activeCourse].meeting_type}
								</ScheduleText>
							</View>
						</View>
						<View style={css.cc_leftHalf_lower}>
							<View style={css.cc_leftHalf_lower_sections}>
								<SimpleIcon style={css.cc_leftHalf_lower_sections_icon} name="clock" />
								<View style={css.cc_leftHalf_lower_sections_text}>
									<ScheduleText style={css.cc_leftHalf_lower_sections_text_topSection}>
										{/* In Session */}
										{coursesToShow[activeCourse].time_string}
									</ScheduleText>
									<ScheduleText style={css.cc_leftHalf_lower_sections_text_bottomSection}>
										Start and Finish Time
									</ScheduleText>
								</View>
							</View>
							<View style={css.cc_leftHalf_lower_sections}>
								<FAIcon style={css.cc_leftHalf_lower_sections_icon} name="building-o" />
								<View style={css.cc_leftHalf_lower_sections_text}>
									<ScheduleText style={css.cc_leftHalf_lower_sections_text_topSection}>
										{/* Pepper Canyon Hall 106 */}
										{coursesToShow[activeCourse].building + ' '
										+ coursesToShow[activeCourse].room}
									</ScheduleText>
									<ScheduleText style={css.cc_leftHalf_lower_sections_text_bottomSection}>
										{/* In Sixth College */}
										Class Room Location
									</ScheduleText>
								</View>
							</View>
							<View style={css.cc_leftHalf_lower_sections}>
								<FAIcon style={css.cc_leftHalf_lower_sections_icon} name="calendar-check-o" />
								<View style={css.cc_leftHalf_lower_sections_text}>
									<ScheduleText style={css.cc_leftHalf_lower_sections_text_topSection}>
										{/* 1 More Class Today */}
										{coursesToShow[activeCourse].grade_option === 'L' ?
											'Letter Grade' : 'Pass/No Pass'}
									</ScheduleText>
									<ScheduleText style={css.cc_leftHalf_lower_sections_text_bottomSection}>
										{/* Last Class Ends at 10:00 AM */}
										Evaluation Option
									</ScheduleText>
								</View>
							</View>
						</View>
					</View>
					<View style={css.cc_rightHalf}>
						<DayItem
							data={coursesToShow[0]}
							active={activeCourse === 0}
							onClick={onClickCourse}
							index={0}
						/>
						<DayItem
							data={coursesToShow[1]}
							active={activeCourse === 1}
							onClick={onClickCourse}
							index={1}
						/>
						<DayItem
							data={coursesToShow[2]}
							active={activeCourse === 2}
							onClick={onClickCourse}
							index={2}
						/>
						<DayItem
							data={coursesToShow[3]}
							active={activeCourse === 3}
							onClick={onClickCourse}
							index={3}
						/>
					</View>
				</View>
				{actionButton}
			</View>
		) : (
			<View style={css.cc_loadingContainer}>
				<ActivityIndicator size="large" />
			</View>
		)}
	</Card>
)

const ScheduleText = ({ style, children }) => (
	<Text
		numberOfLines={1}
		ellipsizeMode="tail"
		allowFontScaling={false}
		style={[
			{
				lineHeight: (() => Math.round(StyleSheet.flatten(style).fontSize * (1.2)))(),
				color: COLOR.VDGREY
			},
			style
		]}
	>
		{children}
	</Text>
)

// Holds the view for an individual section/class
const DayItem = ({ active, data, onClick, index }) => (
	( data ? (
		<TouchableHighlight
			onPress={() => onClick(index)}
			underlayColor={COLOR.LGREY}
			activeOpacity={0.5}
		>
			<View style={[css.cc_rightHalf_eachOfFourCards, active && css.cc_rightHalf_activeCard]}>
				<View style={css.cc_rightHalf_each_dayAndTime}>
					<ScheduleText style={[css.cc_rightHalf_each_dayAndTime_text, !active && css.cc_rightHalf_each_inActiveText]}>
						{schedule.dayOfWeekInterpreter(data.day_code).substring(0, 3) + ' ' + data.time_string}
					</ScheduleText>
					{active && (
						<SimpleIcon style={[css.cc_rightHalf_each_dayAndTime_icon, !active && css.cc_rightHalf_each_inActiveText]} name="pin" />
					)}
				</View>
				<View style={css.cc_rightHalf_each_classAndItsType}>
					<ScheduleText style={[css.cc_rightHalf_each_classAndItsType_class, !active && css.cc_rightHalf_each_inActiveText]}>
						{data.subject_code + ' ' + data.course_code}
					</ScheduleText>
					<ScheduleText style={[css.cc_rightHalf_each_classAndItsType_type, !active && css.cc_rightHalf_each_inActiveText]}>
						{data.meeting_type}
					</ScheduleText>
				</View>
			</View>
		</TouchableHighlight>
	) : null )
)

ScheduleCard.propTypes = {
	coursesToShow: PropTypes.arrayOf(PropTypes.object).isRequired,
	actionButton: PropTypes.element.isRequired,
	onClickCourse: PropTypes.func.isRequired,
	activeCourse: PropTypes.number.isRequired
}

export default ScheduleCard
