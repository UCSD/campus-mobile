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

var dataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

let rightHalf_cardRendered = 0;

const extractAsSimpleList = (scheduleData) => {
	let result = [];
	result.push(...scheduleData.MO);
	result.push(...scheduleData.TU);
	result.push(...scheduleData.WE);
	result.push(...scheduleData.TH);
	result.push(...scheduleData.FR);
	result = result.slice(0,4);
	// console.log(result);
	return result;
}

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
								<Text style = {styles.leftHalf_upper_classText_firstSection} adjustsFontSizeToFit = {true}>
									CSE 198
								</Text>
								<Text style = {styles.leftHalf_upper_classText_secondSection}>
									Lecture
								</Text>
							</View>
							{/* <TextInput style={{height:20, width:150, fontSize:20, color: COLOR_VDGREY }} value={'Class Time Label'} editable={false} ref={component=> this.timeLabel=component}/>  */}
							{/* <TextInput style={{height:36, width:150, fontSize:36, fontWeight:'bold'}} value ={'Course Label'} editable={false} ref={component=> this.courseLabel=component} />  */}
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
							
							{/* <Text style={{fontSize:20}}>
								{"In session"}
							</Text>
							
							<View>
								<TextInput style={{height:20, width:150, fontSize:20}} value = 'Location Label' editable={false} ref={component=> this.locationLabel=component} /> 
							</View>
							
							<Text style={{fontSize:20}}>
									1 More Class Today
							</Text>	 */}
						</View>
					</View>
					<View style={styles.rightHalf}>
						<ListView
							contentContainerStyle={styles.rightHalf_allFourCards}
							dataSource={dataSource.cloneWithRows(extractAsSimpleList(scheduleData))}
							renderRow={(rowData, sectionID, rowID, highlightRow) => (
								<DayItem
									data={rowData}
								/>
							)}
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

const styles = StyleSheet.create({
	container: { 
		width: MAX_CARD_WIDTH, 
		aspectRatio: 1.6216,
		paddingTop: '5%', 
		paddingBottom: '5%', 
		paddingLeft: '4%', 
		paddingRight: '4%', 
		flexDirection:'row', 
	},
	leftHalf: {flex: 6,},
	leftHalf_upper: {height: '30%',},
	leftHalf_upper_timeText: {flex: 1, flexDirection: 'row', },
	leftHalf_upper_timeText_firstSection: {fontSize: 16, marginLeft: 2, marginRight: 3, fontWeight: 'bold'},
	leftHalf_upper_timeText_secondSection: {fontSize: 12, alignSelf: 'flex-end', fontWeight: 'bold'},
	leftHalf_upper_classText: {flex: 2, flexDirection: 'row', top: '-1%'},
	leftHalf_upper_classText_firstSection: {fontSize: 34, fontWeight: 'bold', marginRight: '3%',},
	leftHalf_upper_classText_secondSection: {alignSelf: 'flex-end', fontSize: 13, paddingBottom: '0.5%'},

	leftHalf_lower: {},
	leftHalf_lower_sections: {marginTop: '5%', flexDirection: 'row', },
	leftHalf_lower_sections_icon: {fontFamily: 'Material Design Icons', marginRight: '4%', fontSize: 35, },
	leftHalf_lower_sections_text: {},
	leftHalf_lower_sections_text_topSection: {fontSize: 15,},
	leftHalf_lower_sections_text_bottomSection: {fontSize: 10, },
	
	rightHalf: {flex: 4, paddingTop: '1%',},
	rightHalf_allFourCards: {
		flex: 1,
		justifyContent: 'space-between',
	},
	rightHalf_eachOfFourCards: { 
		borderColor: '#707070', 
		borderWidth: 1, 
		borderRadius: 2,
		paddingTop: '2%',
		paddingLeft: '4%',
		overflow: 'hidden',
		width: '100%', 
		aspectRatio: 3.16,
	},
	more: { alignItems: 'center', justifyContent: 'center', padding: 6 },
	more_label: { fontSize: 20, color: COLOR_PRIMARY, fontWeight: '300' },
	specialEventsListView: { borderBottomWidth: 1, borderBottomColor: COLOR_MGREY },
	nextClassContainer: { flexGrow: 1, width: MAX_CARD_WIDTH },
	contentContainer: { flexShrink: 1, width: MAX_CARD_WIDTH },
	fullScheduleButton: { width: MAX_CARD_WIDTH, backgroundColor: COLOR_LGREY, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingVertical: 8, borderTopWidth: 1, borderBottomWidth: 1, borderColor: COLOR_MGREY },
	loadingContainer: { alignItems: 'center', justifyContent: 'center', width: MAX_CARD_WIDTH },
	scheduleList: { flex: 1, justifyContent: 'flex-end', alignItems: 'flex-end'},
	dayListStyle: {flex: 1, paddingRight: 10 /* align0 Items:'flex-end'*/},
	sc_scheduleCard: { width: MAX_CARD_WIDTH + 2, padding: 0, flexDirection:'column', flex: 1},
	sc_dayText: { fontSize: 16, color: COLOR_BLACK, /*paddingBottom: 6 */},
	dc_locations_row_right: { flex: 6 },
	
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
			<Text style={{fontSize: 10, color: COLOR_VDGREY}}>
					{dayOfWeekIntepreter(data.day_code) + ' ' + data.time_string}
			</Text>
			<View style={{flexDirection:'row', top: '-0%'}}>
				<Text style={{fontSize: 18, color: COLOR_VDGREY, flex: 3}}>
					{data.subject_code + ' ' + data.course_code}
				</Text>
				<Text style={{fontSize: 10, color: COLOR_VDGREY, flex: 2, alignSelf:'flex-end', paddingBottom: '4%'}} >
					{data.meeting_type}
				</Text>
			</View>
		</View>
	</TouchableHighlight>
);

ScheduleCard.propTypes = {
	scheduleData: PropTypes.object,
	actionButton: PropTypes.element
};

export default ScheduleCard;
