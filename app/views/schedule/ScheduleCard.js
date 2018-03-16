import React, { PropTypes } from 'react';
import {
	View,
	Text,
	ListView,
	StyleSheet,
	TouchableHighlight,
	ActivityIndicator,
	TextInput
} from 'react-native';

import { getClasses, getFinals, dayOfWeekIntepreter } from './scheduleData';
import { FullScheduleListView } from './FullScheduleListView';
import ScrollCard from '../card/ScrollCard';
import Card from '../card/Card';
import FullScheduleButton from './FullScheduleButton';

import Touchable from '../common/Touchable';
import logger from '../../util/logger';
import Icon from 'react-native-vector-icons/Ionicons';
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
import {
	MAX_CARD_WIDTH,
} from '../../styles/LayoutConstants';

const ScheduleCard = ({ scheduleData, actionButton }) => (
	<Card id="schedule" title="Upcoming Classes" >
		{scheduleData ? (
			<View style={styles.sc_scheduleCard}>
				<View style={styles.container}>
					{/* <TouchableHighlight style={styles.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={() => general.gotoNavigationApp(data.coords.lat, data.coords.lon)}>
						<View style={css.dl_dir_traveltype_container}>
							<Icon name="md-walk" size={32} color={COLOR_SECONDARY} />
						</View>
					</TouchableHighlight> */}
		 			<View style = {styles.leftHalf}>
						<View style = {styles.leftHalf_upper}>
							<View style = {styles.leftHalf_upper_timeText}>
								<Text style = {styles.leftHalf_upper_timeText_firstSection}>
									Today 9
								</Text>
								<Text style = {styles.leftHalf_upper_timeText_secondSection}>
									AM 
								</Text>
							</View>
							<View style = {styles.leftHalf_upper_classText}>
								<Text style = {styles.leftHalf_upper_classText_firstSection}>
									CSE 198
								</Text>
								<Text style = {styles.leftHalf_upper_classText_secondSection}>
									Lecture
								</Text>
							</View>
						</View>
						<View style = {styles.leftHalf_lower}>
							<View style = {styles.leftHalf_lower_sections}>
								<Text style = {styles.leftHalf_lower_sections_icon}>
									
								</Text>
								<View style = {styles.leftHalf_lower_sections_text}>
									<Text style = {styles.leftHalf_lower_sections_text_topSection}>
										In Session
									</Text>
									<Text style = {styles.leftHalf_lower_sections_text_bottomSection}>
										9:00 AM to 9:50 AM
									</Text>
								</View>
							</View>
							<View style = {styles.leftHalf_lower_sections}>
								<Text style = {styles.leftHalf_lower_sections_icon}>
									
								</Text>
								<View style = {styles.leftHalf_lower_sections_text}>
									<Text style = {styles.leftHalf_lower_sections_text_topSection}>
										Pepper Canyon Hall 106
									</Text>
									<Text style = {styles.leftHalf_lower_sections_text_bottomSection}>
										In Sixth College
									</Text>
								</View>
							</View>
							<View style = {styles.leftHalf_lower_sections}>
								<Text style = {styles.leftHalf_lower_sections_icon}>
									
								</Text>
								<View style = {styles.leftHalf_lower_sections_text}>
									<Text style = {styles.leftHalf_lower_sections_text_topSection}>
										1 More Class Today
									</Text>
									<Text style = {styles.leftHalf_lower_sections_text_bottomSection}>
										Last Class Ends at 10:00 AM
									</Text>
								</View>
							</View>
						</View>
					</View>
					<View style={styles.rightHalf}>
						<DayItem data={scheduleData[0]} />
						<DayItem data={scheduleData[1]} />
						<DayItem data={scheduleData[2]} />
						<DayItem data={scheduleData[3]} />
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

const C = {
	L : MAX_CARD_WIDTH * 0.006,
	R : MAX_CARD_WIDTH * 0.004
};

const styles = StyleSheet.create({
	container: { 
		width: MAX_CARD_WIDTH, 
		aspectRatio: 1.6216,
		paddingTop: MAX_CARD_WIDTH * 0.05, 
		paddingBottom: MAX_CARD_WIDTH * 0.05, 
		paddingLeft: MAX_CARD_WIDTH * 0.04, 
		paddingRight: MAX_CARD_WIDTH * 0.04, 
		flexDirection:'row', 
	},
	leftHalf: {flex: 6,},
	leftHalf_upper: {flex: 3,},
	leftHalf_upper_timeText: {flex: 1, flexDirection: 'row', },
	leftHalf_upper_timeText_firstSection: {fontSize: C.L*7, marginLeft: C.L*1, marginRight: C.L*1, fontWeight: 'bold'},
	leftHalf_upper_timeText_secondSection: {fontSize: C.L*5, alignSelf: 'flex-end', marginBottom: C.L*0.5, fontWeight: 'bold'},
	leftHalf_upper_classText: {flex: 2, flexDirection: 'row', top: -C.L*0},
	leftHalf_upper_classText_firstSection: {fontSize: C.L*15, fontWeight: 'bold', marginRight: C.L*3, overflow: 'hidden',},
	leftHalf_upper_classText_secondSection: {fontSize: C.L*6, alignSelf: 'flex-end', fontSize: C.L*5, paddingBottom: C.L*1.5},

	leftHalf_lower: {flex: 7},
	leftHalf_lower_sections: {marginTop: C.L*4, flexDirection: 'row', },
	leftHalf_lower_sections_icon: {fontFamily: 'Material Design Icons', fontSize: C.L*15.5, marginRight: C.L*4, },
	leftHalf_lower_sections_text: {},
	leftHalf_lower_sections_text_topSection: {fontSize: C.L*6, paddingTop: C.L*0.25},
	leftHalf_lower_sections_text_bottomSection: {fontSize: C.L*4.5, paddingTop: C.L*1},
	
	rightHalf: {flex: 4, paddingTop: C.R*0.5, justifyContent: 'space-between'},
	rightHalf_eachOfFourCards: { 
		borderColor: '#707070', 
		borderWidth: C.R*1, 
		borderRadius: C.R*1.5,
		paddingLeft: C.R*3,
		overflow: 'hidden',
		width: '100%', 
		aspectRatio: 3.16,
	},
	rightHalf_each_dayAndTime: {flexDirection:'row',},
	rightHalf_each_dayAndTime_text: {flex: 8,fontSize: C.R*6.5, paddingTop: C.R*2.5, color: COLOR_VDGREY},
	rightHalf_each_dayAndTime_icon: {flex: 2,fontSize: C.R*9, color: COLOR_VDGREY, top: -C.R*1.5, fontFamily: 'Material Design Icons',},
	rightHalf_each_classAndItsType: {flexDirection:'row', top: C.R*1},
	rightHalf_each_classAndItsType_class: {flex: 3, fontSize: C.R*11, color: COLOR_VDGREY, },
	rightHalf_each_classAndItsType_type: {flex: 2, fontSize: C.R*6, color: COLOR_VDGREY, alignSelf:'flex-end', paddingBottom: C.R*1},
});

// Holds the view for an individual section/class 
var DayItem = ({ data }) => (
	<TouchableHighlight //onPress= {
		// ()=>{this.courseLabel.setNativeProps({text: data.subject_code + ' ' + data.course_code})
		// this.timeLabel.setNativeProps({text: data.day_code + ' ' + data.time_string}) 
		// this.locationLabel.setNativeProps({text: data.building + ' ' + data.room}) }
		// }
		> 
		<View style={styles.rightHalf_eachOfFourCards}>
			<View style={styles.rightHalf_each_dayAndTime}>
				<Text style={styles.rightHalf_each_dayAndTime_text}>
						{dayOfWeekIntepreter(data.day_code).substring(0,3) + ' ' + data.time_string}
				</Text>
				<Text style={styles.rightHalf_each_dayAndTime_icon}>
					
				</Text>
			</View>
			<View style={styles.rightHalf_each_classAndItsType}>
				<Text style={styles.rightHalf_each_classAndItsType_class}>
					{data.subject_code + ' ' + data.course_code}
				</Text>
				<Text style={styles.rightHalf_each_classAndItsType_type} >
					{data.meeting_type}
				</Text>
			</View>
		</View>
	</TouchableHighlight>
);

ScheduleCard.propTypes = {
	scheduleData: PropTypes.array,
	actionButton: PropTypes.element
};

export default ScheduleCard;
