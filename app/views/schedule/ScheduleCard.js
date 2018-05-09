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

import schedule from '../../util/schedule'
import Card from '../common/Card'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

const ScheduleCard = ({
	coursesToShow,
	waitingData,
	actionButton,
	activeCourse,
	currentTerm,
	onClickCourse
}) => (
	<Card id="schedule" title="Classes">
		{(!waitingData) ? (
			(currentTerm && currentTerm.term_code !== 'inactive') ?
				(
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
									<ScheduleText style={css.cc_leftHalf_upper_classText_firstSection}>
										{coursesToShow[activeCourse].subject_code + ' '
											+ coursesToShow[activeCourse].course_code}
									</ScheduleText>
									<ScheduleText style={css.cc_leftHalf_upper_classText_secondSection}>
										{coursesToShow[activeCourse].meeting_type}
									</ScheduleText>
								</View>
								<View style={css.cc_leftHalf_lower}>
									<View style={css.cc_leftHalf_lower_sections}>
										<FAIcon style={css.cc_icon_time} size={42} name="clock-o" />
										<View style={css.cc_leftHalf_lower_sections_text}>
											<ScheduleText style={css.cc_leftHalf_lower_sections_text_bottomSection}>
												Start and Finish Time
											</ScheduleText>
											<ScheduleText style={css.cc_leftHalf_lower_sections_text_topSection}>
												{/* In Session */}
												{coursesToShow[activeCourse].time_string}
											</ScheduleText>
										</View>
									</View>
									<View style={css.cc_leftHalf_lower_sections}>
										<FAIcon style={css.cc_icon_building} size={42} name="building-o" />
										<View style={css.cc_leftHalf_lower_sections_text}>
											<ScheduleText style={css.cc_leftHalf_lower_sections_text_bottomSection}>
												{/* In Sixth College */}
												Class Room Location
											</ScheduleText>
											<ScheduleText style={css.cc_leftHalf_lower_sections_text_topSection}>
												{/* Pepper Canyon Hall 106 */}
												{coursesToShow[activeCourse].building + ' '
												+ coursesToShow[activeCourse].room}
											</ScheduleText>
										</View>
									</View>
									<View style={css.cc_leftHalf_lower_sections}>
										<FAIcon style={css.cc_icon_lettergrade} size={42} name="check-square-o" />
										<View style={css.cc_leftHalf_lower_sections_text}>
											<ScheduleText style={css.cc_leftHalf_lower_sections_text_bottomSection}>
												{/* Last Class Ends at 10:00 AM */}
												Evaluation Option
											</ScheduleText>
											<ScheduleText style={css.cc_leftHalf_lower_sections_text_topSection}>
												{/* 1 More Class Today */}
												{coursesToShow[activeCourse].grade_option === 'L' ?
													'Letter Grade' : 'Pass/No Pass'}
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
						<Text>No classes to display right now.</Text>)
					</View>
				)
		) : (
			// If we are waiting for data, show loading indicator
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
				<ScheduleText style={[css.cc_rightHalf_each_daytime_text, !active && css.cc_rightHalf_each_inActiveText]}>
					{schedule.dayOfWeekInterpreter(data.day_code).substring(0, 3) + ' @ ' + data.start_string}
				</ScheduleText>
				<ScheduleText style={[css.cc_rightHalf_each_class_text, !active && css.cc_rightHalf_each_inActiveText]}>
					{data.subject_code + ' ' + data.course_code}
				</ScheduleText>
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
