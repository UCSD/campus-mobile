import React, { PropTypes } from 'react';
import {
	View,
	Text,
	StyleSheet,
	TouchableHighlight,
	ActivityIndicator
} from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';

import { dayOfWeekInterpreter } from './scheduleData';
import Card from '../card/Card';

import css from '../../styles/css';
import {
	COLOR_DGREY,
	COLOR_MGREY,
	COLOR_PRIMARY,
	COLOR_LGREY,
	COLOR_SECONDARY,
	COLOR_BLACK,
	COLOR_VDGREY
} from '../../styles/ColorConstants';
import { MAX_CARD_WIDTH } from '../../styles/LayoutConstants';

const ScheduleCard = (props) => {
	const { coursesToShow, actionButton } = props;
	return (
		<Card id="schedule" title="Upcoming Classes">
			{coursesToShow ? (
				<View style={styles.sc_scheduleCard}>
					<View style={styles.container}>
						<View style={styles.leftHalf}>
							<View style={styles.leftHalf_upper}>
								<View style={styles.leftHalf_upper_timeText}>
									<Text style={styles.leftHalf_upper_timeText_firstSection}>
										{props.mainDisplay.leftHalf_upper_timeText_firstSection}
									</Text>
									<Text style={styles.leftHalf_upper_timeText_secondSection}>
										{props.mainDisplay.leftHalf_upper_timeText_secondSection}
									</Text>
								</View>
								<View style={styles.leftHalf_upper_classText}>
									<Text style={styles.leftHalf_upper_classText_firstSection}>
										{props.mainDisplay.leftHalf_upper_classText_firstSection}
									</Text>
									<Text style={styles.leftHalf_upper_classText_secondSection}>
										{props.mainDisplay.leftHalf_upper_classText_secondSection}
									</Text>
								</View>
							</View>
							<View style={styles.leftHalf_lower}>
								<View style={styles.leftHalf_lower_sections}>
									<Text style={styles.leftHalf_lower_sections_icon}></Text>
									<View style={styles.leftHalf_lower_sections_text}>
										<Text style={styles.leftHalf_lower_sections_text_topSection}>
											{props.mainDisplay.leftHalf_lower_sections_text1_topSection}
										</Text>
										<Text style={styles.leftHalf_lower_sections_text_bottomSection}>
											{props.mainDisplay.leftHalf_lower_sections_text1_bottomSection}
										</Text>
									</View>
								</View>
								<View style={styles.leftHalf_lower_sections}>
									<Text style={styles.leftHalf_lower_sections_icon}></Text>
									<View style={styles.leftHalf_lower_sections_text}>
										<Text style={styles.leftHalf_lower_sections_text_topSection}>
											{props.mainDisplay.leftHalf_lower_sections_text2_topSection}
										</Text>
										<Text style={styles.leftHalf_lower_sections_text_bottomSection}>
											{props.mainDisplay.leftHalf_lower_sections_text2_bottomSection}
										</Text>
									</View>
								</View>
								<View style={styles.leftHalf_lower_sections}>
									<Text style={styles.leftHalf_lower_sections_icon}></Text>
									<View style={styles.leftHalf_lower_sections_text}>
										<Text style={styles.leftHalf_lower_sections_text_topSection}>
											{props.mainDisplay.leftHalf_lower_sections_text3_topSection}
										</Text>
										<Text style={styles.leftHalf_lower_sections_text_bottomSection}>
											{props.mainDisplay.leftHalf_lower_sections_text3_bottomSection}
										</Text>
									</View>
								</View>
							</View>
						</View>
						<View style={styles.rightHalf}>
							<DayItem
								data={coursesToShow[0]}
								active={props.activeCourse === 0}
								onClick={props.onClickCourse}
								index={0}
							/>
							<DayItem
								data={coursesToShow[1]}
								active={props.activeCourse === 1}
								onClick={props.onClickCourse}
								index={1}
							/>
							<DayItem
								data={coursesToShow[2]}
								active={props.activeCourse === 2}
								onClick={props.onClickCourse}
								index={2}
							/>
							<DayItem
								data={coursesToShow[3]}
								active={props.activeCourse === 3}
								onClick={props.onClickCourse}
								index={3}
							/>
						</View>
					</View>
					{actionButton}
				</View>
			) : (
				<View style={css.loadingContainer}>
					{' '}
					<ActivityIndicator size="large" />
				</View>
			)}
		</Card>
	);
};

const C = {
	L: MAX_CARD_WIDTH * 0.006,
	R: MAX_CARD_WIDTH * 0.004
};

const styles = StyleSheet.create({
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
		fontWeight: 'bold'
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
		overflow: 'hidden'
	},
	leftHalf_upper_classText_secondSection: {
		fontSize: C.L * 5,
		alignSelf: 'flex-end',
		paddingBottom: C.L * 1.5
	},

	leftHalf_lower: { flex: 7 },
	leftHalf_lower_sections: { marginTop: C.L * 3.75, flexDirection: 'row' },
	leftHalf_lower_sections_icon: {
		fontFamily: 'Material Design Icons',
		fontSize: C.L * 15.5,
		marginRight: C.L * 4
	},
	leftHalf_lower_sections_text: {},
	leftHalf_lower_sections_text_topSection: {
		fontSize: C.L * 6,
		paddingTop: C.L * 0.25
	},
	leftHalf_lower_sections_text_bottomSection: {
		fontSize: C.L * 4.5,
		paddingTop: C.L * 1
	},

	rightHalf: {
		flex: 4,
		paddingTop: C.R * 0.5,
		justifyContent: 'space-between'
	},
	rightHalf_activeCard: {
		borderColor: '#707070'
	// borderWidth: C.R * 1,
	},
	rightHalf_eachOfFourCards: {
		borderColor: '#707070',
		borderWidth: C.R * 0.5,
		borderRadius: C.R * 1.5,
		paddingLeft: C.R * 4,
		overflow: 'hidden',
		width: '100%',
		aspectRatio: 3.16
	},
	rightHalf_each_dayAndTime: { flexDirection: 'row' },
	rightHalf_each_dayAndTime_text: {
		flex: 8,
		fontSize: C.R * 6.5,
		paddingTop: C.R * 3.25,
		color: COLOR_VDGREY
	},
	rightHalf_each_dayAndTime_icon: {
		flex: 2,
		fontSize: C.R * 9,
		color: COLOR_VDGREY,
		top: -C.R * 1.5,
		fontFamily: 'Material Design Icons'
	},
	rightHalf_each_classAndItsType: { flexDirection: 'row', top: C.R * 1 },
	rightHalf_each_classAndItsType_class: {
		flex: 3,
		fontSize: C.R * 11,
		color: COLOR_VDGREY
	},
	rightHalf_each_classAndItsType_type: {
		flex: 2,
		fontSize: C.R * 6,
		color: COLOR_VDGREY,
		alignSelf: 'flex-end',
		paddingBottom: C.R * 1
	}
});

// Holds the view for an individual section/class
const DayItem = (props) => {
	const { data } = props;
	return (
		<TouchableHighlight
			onPress={() => props.onClick(props.index)}
			underlayColor={COLOR_LGREY}
			activeOpacity={0.5}
		>
			<View style={[styles.rightHalf_eachOfFourCards, props.active && styles.rightHalf_activeCard]}>
				<View style={styles.rightHalf_each_dayAndTime}>
					<Text style={styles.rightHalf_each_dayAndTime_text}>
						{dayOfWeekInterpreter(data.day_code).substring(0, 3) + ' ' + data.time_string}
					</Text>
					{props.active && (
						<Text style={styles.rightHalf_each_dayAndTime_icon}></Text>
					)}
				</View>
				<View style={styles.rightHalf_each_classAndItsType}>
					<Text style={styles.rightHalf_each_classAndItsType_class}>
						{data.subject_code + ' ' + data.course_code}
					</Text>
					<Text style={styles.rightHalf_each_classAndItsType_type}>
						{data.meeting_type}
					</Text>
				</View>
			</View>
		</TouchableHighlight>
	);
};

ScheduleCard.propTypes = {
	coursesToShow: PropTypes.arrayOf(PropTypes.object).isRequired,
	actionButton: PropTypes.element.isRequired,
	mainDisplay: PropTypes.objectOf(PropTypes.string).isRequired,
	onClickCourse: PropTypes.func.isRequired,
	activeCourse: PropTypes.number.isRequired
};

export default ScheduleCard;
