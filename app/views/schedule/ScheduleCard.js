import React from 'react'
import {
	View,
	Text,
	StyleSheet,
	TouchableHighlight,
	ActivityIndicator
} from 'react-native'
import FAIcon from 'react-native-vector-icons/FontAwesome'

import schedule from '../../util/schedule'
import logger from '../../util/logger'
import Card from '../common/Card'
import LastUpdated from '../common/LastUpdated'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

const ScheduleCard = ({
	coursesToShow,
	totalClasses,
	waitingData,
	lastUpdated,
	error,
	actionButton,
	activeCourse,
	currentTerm,
	onClickCourse
}) => {
	try {
		if (coursesToShow && coursesToShow[activeCourse] && currentTerm.term_code) {
			const currentCourse = coursesToShow[activeCourse]

			// Get values for view and account for optional values
			let classTime,
				classLocation,
				classEval

			if (currentCourse.time_string) {
				classTime = currentCourse.time_string
			} else {
				classTime = 'No Time Associated'
			}

			if (currentCourse.building) {
				classLocation = currentCourse.building + ' ' +
					currentCourse.room
			} else {
				classLocation = 'No Location Associated'
			}

			switch (currentCourse.grade_option) {
				case 'L': {
					classEval = 'Letter Grade'
					break
				}
				case 'P': {
					classEval = 'Pass/No Pass'
					break
				}
				case 'S': {
					classEval = 'Sat/Unsat'
					break
				}
				default: {
					classEval = 'Other'
				}
			}

			return (
				<Card id="schedule" title="Classes">
					<View style={css.cc_container}>
						<View style={css.cc_leftHalf}>
							<View style={css.cc_leftHalf_upper}>
								<ScheduleText style={css.cc_leftHalf_upper_timeText}>
									{schedule.dayOfWeekInterpreter(currentCourse.day_code)}
								</ScheduleText>
								<ScheduleText style={css.cc_leftHalf_upper_classText_firstSection}>
									{currentCourse.subject_code + ' '
										+ currentCourse.course_code}
								</ScheduleText>
								<ScheduleText style={css.cc_leftHalf_upper_classText_secondSection}>
									{currentCourse.meeting_type}
								</ScheduleText>
							</View>
							<View style={css.cc_leftHalf_lower}>
								<ClassMetaWithIcon
									icon="clock-o"
									iconStyle={css.cc_icon_time}
									description="Start and Finish Time"
									value={classTime}
								/>
								<ClassMetaWithIcon
									icon="building-o"
									iconStyle={css.cc_icon_building}
									description="Class Room Location"
									value={classLocation}
								/>
								<ClassMetaWithIcon
									icon="check-square-o"
									iconStyle={css.cc_icon_lettergrade}
									description="Evaluation Option"
									value={classEval}
								/>
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
					<LastUpdatedMin lastUpdated={lastUpdated} error={error} />
					{actionButton}
				</Card>
			)
		} else if (totalClasses > 0) {
			return <NoClasses lastUpdated={lastUpdated} error={error} actionButton={actionButton} />
		} else {
			return <LoadingClasses lastUpdated={lastUpdated} error={error} />
		}
	} catch (err) {
		return <LoadingClasses lastUpdated={lastUpdated} error={error} />
	}
}

const LastUpdatedMin = ({ lastUpdated, error }) => (
	<LastUpdated
		style={css.cc_last_updated}
		lastUpdated={lastUpdated}
		error={
			(error === 'App update required.') ?
				('App update required.') :
				(null)
		}
		warning={
			(error) ?
				('We\'re having trouble updating right now.') :
				(null)
		}
	/>
)

const LoadingClasses = ({ lastUpdated, error }) => (
	<Card id="schedule" title="Classes">
		<View style={css.cc_loadingContainer}>
			<ActivityIndicator size="large" />
		</View>
		<LastUpdatedMin lastUpdated={lastUpdated} error={error} />
	</Card>
)

const NoClasses = ({ lastUpdated, error, actionButton }) => (
	<Card id="schedule" title="Classes">
		<View style={css.cc_loadingContainer}>
			<Text style={css.cc_noclasses}>
				You do not have any classes today.
			</Text>
		</View>
		<LastUpdatedMin lastUpdated={lastUpdated} error={error} />
		{actionButton}
	</Card>
)

const ClassMetaWithIcon = ({ icon, iconStyle, description, value }) => (
	<View style={css.cc_leftHalf_lower_sections}>
		<FAIcon style={iconStyle} size={42} name={icon} />
		<View style={css.cc_leftHalf_lower_sections_text}>
			<ScheduleText style={css.cc_leftHalf_lower_sections_text_bottomSection}>
				{description}
			</ScheduleText>
			<ScheduleText style={css.cc_leftHalf_lower_sections_text_topSection}>
				{value}
			</ScheduleText>
		</View>
	</View>
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
const DayItem = ({ active, data, onClick, index }) => {
	if (!data) return null

	const day = schedule.dayOfWeekInterpreter(data.day_code)

	let shortenedDay
	if (day === 'Other' ) shortenedDay = day
	else shortenedDay = day.substring(0,3)

	let hour = ''
	if (data.start_string) hour = ' @ ' + data.start_string

	return (
		<TouchableHighlight
			onPress={() => onClick(index)}
			underlayColor={COLOR.LGREY}
			activeOpacity={0.5}
			style={{ marginBottom: 8 }}
		>
			<View style={[css.cc_rightHalf_eachOfFourCards, active && css.cc_rightHalf_activeCard]}>
				<ScheduleText style={[css.cc_rightHalf_each_daytime_text, !active && css.cc_rightHalf_each_inActiveText]}>
					{ shortenedDay + hour }
				</ScheduleText>
				<ScheduleText style={[css.cc_rightHalf_each_class_text, !active && css.cc_rightHalf_each_inActiveText]}>
					{data.subject_code + ' ' + data.course_code}
				</ScheduleText>
			</View>
		</TouchableHighlight>
	)
}

export default ScheduleCard
