import React from 'react';
import PropTypes from 'prop-types';
import {
	View,
	Text,
	StyleSheet,
	TouchableHighlight,
	ActivityIndicator
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import SimpleIcon from 'react-native-vector-icons/SimpleLineIcons';

import schedule from '../../util/schedule';
import Card from '../card/Card';

// import css from '../../styles/css';
import {
	// COLOR_PRIMARY,
	COLOR_LGREY,
	// COLOR_SECONDARY,
	// COLOR_BLACK,
	COLOR_VDGREY,
	COLOR_DGREY,
} from '../../styles/ColorConstants';
import { MAX_CARD_WIDTH } from '../../styles/LayoutConstants';

const ScheduleCard = ({
	coursesToShow,
	actionButton,
	activeCourse,
	onClickCourse
}) => (
	<Card id="schedule" title="Upcoming Classes">
		{coursesToShow.length ? (
			<View style={styles.sc_scheduleCard}>
				<View style={styles.container}>
					<View style={styles.leftHalf}>
						<View style={styles.leftHalf_upper}>
							<View style={styles.leftHalf_upper_timeText}>
								<ScheduleText style={styles.leftHalf_upper_timeText_firstSection}>
									{/* Today 9 */}
									{schedule.dayOfWeekInterpreter(coursesToShow[activeCourse].day_code)}
								</ScheduleText>
								<ScheduleText style={styles.leftHalf_upper_timeText_secondSection}>
									{/* AM */}
								</ScheduleText>
							</View>
							<View style={styles.leftHalf_upper_classText}>
								<ScheduleText style={styles.leftHalf_upper_classText_firstSection}>
									{coursesToShow[activeCourse].subject_code + ' '
										+ coursesToShow[activeCourse].course_code}
								</ScheduleText>
								<ScheduleText style={styles.leftHalf_upper_classText_secondSection}>
									{coursesToShow[activeCourse].meeting_type}
								</ScheduleText>
							</View>
						</View>
						<View style={styles.leftHalf_lower}>
							<View style={styles.leftHalf_lower_sections}>
								<SimpleIcon style={styles.leftHalf_lower_sections_icon} name="clock" />
								<View style={styles.leftHalf_lower_sections_text}>
									<ScheduleText style={styles.leftHalf_lower_sections_text_topSection}>
										{/* In Session */}
										{coursesToShow[activeCourse].time_string}
									</ScheduleText>
									<ScheduleText style={styles.leftHalf_lower_sections_text_bottomSection}>
										Start and Finish Time
									</ScheduleText>
								</View>
							</View>
							<View style={styles.leftHalf_lower_sections}>
								<Icon style={styles.leftHalf_lower_sections_icon} name="location-arrow" />
								<View style={styles.leftHalf_lower_sections_text}>
									<ScheduleText style={styles.leftHalf_lower_sections_text_topSection}>
										{/* Pepper Canyon Hall 106 */}
										{coursesToShow[activeCourse].building + ' '
										+ coursesToShow[activeCourse].room}
									</ScheduleText>
									<ScheduleText style={styles.leftHalf_lower_sections_text_bottomSection}>
										{/* In Sixth College */}
										Class Room Location
									</ScheduleText>
								</View>
							</View>
							<View style={styles.leftHalf_lower_sections}>
								<Icon style={styles.leftHalf_lower_sections_icon} name="calendar-check-o" />
								<View style={styles.leftHalf_lower_sections_text}>
									<ScheduleText style={styles.leftHalf_lower_sections_text_topSection}>
										{/* 1 More Class Today */}
										{coursesToShow[activeCourse].grade_option === 'L' ?
											'Letter Grade' : 'Pass/No Pass'}
									</ScheduleText>
									<ScheduleText style={styles.leftHalf_lower_sections_text_bottomSection}>
										{/* Last Class Ends at 10:00 AM */}
										Evaluation Option
									</ScheduleText>
								</View>
							</View>
						</View>
					</View>
					<View style={styles.rightHalf}>
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
			<View style={styles.loadingContainer}>
				<ActivityIndicator size="large" />
			</View>
		)}
	</Card>
);

const ScheduleText = ({ style, children}) => (
	<Text
		numberOfLines={1}
		ellipsizeMode="tail"
		allowFontScaling={false}
		style={[
			{
				lineHeight: (() => Math.round(StyleSheet.flatten(style).fontSize * (1.2)))(),
				color: COLOR_VDGREY
			},
			style]}
	>
		{children}
	</Text>
);

const C = {
	L: MAX_CARD_WIDTH * 0.006,
	R: MAX_CARD_WIDTH * 0.004
};

const styles = StyleSheet.create({
	loadingContainer: {
		alignItems: 'center',
		justifyContent: 'center',
		width: MAX_CARD_WIDTH ,
		height: (MAX_CARD_WIDTH / 1.6216) + 44
	},
	container: {
		width: MAX_CARD_WIDTH,
		aspectRatio: 1.6216,
		paddingTop: MAX_CARD_WIDTH * 0.05,
		paddingBottom: MAX_CARD_WIDTH * 0.05,
		paddingLeft: MAX_CARD_WIDTH * 0.04,
		paddingRight: MAX_CARD_WIDTH * 0.04,
		flexDirection: 'row'
	},
	leftHalf: { flex: 6 },
	leftHalf_upper: { flex: 3 },
	leftHalf_upper_timeText: { flex: 1, flexDirection: 'row' },
	leftHalf_upper_timeText_firstSection: {
		fontSize: C.L * 7,
		marginLeft: C.L * 1,
		marginRight: C.L * 1,
		// fontWeight: 'bold',
		color: COLOR_DGREY
	},
	leftHalf_upper_timeText_secondSection: {
		fontSize: C.L * 5,
		alignSelf: 'flex-end',
		marginBottom: C.L * 0.5,
		fontWeight: 'bold'
	},
	leftHalf_upper_classText: { flex: 2, flexDirection: 'row', top: -C.L * 0 },
	leftHalf_upper_classText_firstSection: {
		fontSize: C.L * 15,
		fontWeight: 'bold',
		marginRight: C.L * 3,
		overflow: 'hidden',
	},
	leftHalf_upper_classText_secondSection: {
		fontSize: C.L * 5,
		alignSelf: 'flex-end',
		marginBottom: Math.round(C.L * 15 * 1.2) * 0.12,
		color : COLOR_DGREY
	},

	leftHalf_lower: { flex: 7 },
	leftHalf_lower_sections: { marginTop: C.L * 3.75, flexDirection: 'row' },
	leftHalf_lower_sections_icon: {
		fontFamily: 'Material Design Icons',
		fontSize: C.L * 15.5,
		marginRight: C.L * 4,
		lineHeight: Math.round(C.L * 16),
		top: -C.L * 0.5,
	},
	leftHalf_lower_sections_text: {},
	leftHalf_lower_sections_text_topSection: {
		fontSize: C.L * 6,
		paddingTop: C.L * 0.25
	},
	leftHalf_lower_sections_text_bottomSection: {
		fontSize: C.L * 4.5,
		paddingTop: C.L * 1,
		color: COLOR_DGREY
	},

	rightHalf: {
		flex: 4,
		paddingTop: C.R * 0.5,
		justifyContent: 'space-between'
	},
	rightHalf_eachOfFourCards: {
		borderColor: COLOR_DGREY,
		borderWidth: C.R * 0.5,
		borderRadius: C.R * 1,
		paddingLeft: C.R * 4,
		paddingTop: C.R * 2.5,
		overflow: 'hidden',
		width: '100%',
		aspectRatio: 3.16,
	},
	rightHalf_activeCard: {
		borderColor: COLOR_VDGREY,
		borderWidth: C.R * 0.75,
		paddingLeft: C.R * 3.75,
		paddingTop: C.R * 2.25,
	},
	rightHalf_each_dayAndTime: {
		flexDirection: 'row',
		height: Math.round(C.R * 9)
	},
	rightHalf_each_dayAndTime_text: {
		width: C.R * 70,
		fontSize: C.R * 6.5,
	},
	rightHalf_each_dayAndTime_icon: {
		fontSize: C.R * 9,
		top: -C.R * 3,
		fontFamily: 'Material Design Icons',
		lineHeight: Math.round(C.R * 9),
	},
	rightHalf_each_classAndItsType: { flexDirection: 'row', top: C.R * 1 },
	rightHalf_each_classAndItsType_class: {
		width: C.R * 55,
		fontSize: C.R * 11,
	},
	rightHalf_each_classAndItsType_type: {
		fontSize: C.R * 6,
		alignSelf: 'flex-end',
		paddingBottom: C.R * 1
	},
	rightHalf_each_inActiveText: {
		color: COLOR_DGREY
	},
});

// Holds the view for an individual section/class
const DayItem = ({
	active,
	data,
	onClick,
	index
}) => (
	(data) ?
		(
			<TouchableHighlight
				onPress={() => onClick(index)}
				underlayColor={COLOR_LGREY}
				activeOpacity={0.5}
			>
				<View style={[styles.rightHalf_eachOfFourCards, active && styles.rightHalf_activeCard]}>
					<View style={styles.rightHalf_each_dayAndTime}>
						<ScheduleText style={[styles.rightHalf_each_dayAndTime_text, !active && styles.rightHalf_each_inActiveText]}>
							{schedule.dayOfWeekInterpreter(data.day_code).substring(0, 3) + ' ' + data.time_string}
						</ScheduleText>
						{active && (
							<SimpleIcon style={[styles.rightHalf_each_dayAndTime_icon, !active && styles.rightHalf_each_inActiveText]} name="pin" />
						)}
					</View>
					<View style={styles.rightHalf_each_classAndItsType}>
						<ScheduleText style={[styles.rightHalf_each_classAndItsType_class, !active && styles.rightHalf_each_inActiveText]}>
							{data.subject_code + ' ' + data.course_code}
						</ScheduleText>
						<ScheduleText style={[styles.rightHalf_each_classAndItsType_type, !active && styles.rightHalf_each_inActiveText]}>
							{data.meeting_type}
						</ScheduleText>
					</View>
				</View>
			</TouchableHighlight>
		) : (null)
);

ScheduleCard.propTypes = {
	coursesToShow: PropTypes.arrayOf(PropTypes.object).isRequired,
	actionButton: PropTypes.element.isRequired,
	onClickCourse: PropTypes.func.isRequired,
	activeCourse: PropTypes.number.isRequired
};

export default ScheduleCard;
