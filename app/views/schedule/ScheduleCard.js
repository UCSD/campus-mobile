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

import { getClasses, getFinals } from './scheduleData';
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
							<TextInput style={{height:20, width:150, fontSize:20, color: COLOR_VDGREY }} value={'Class Time Label'} editable={false} ref={component=> this.timeLabel=component}/> 
							<TextInput style={{height:36, width:150, fontSize:36, fontWeight:'bold'}} value ={'Course Label'} editable={false} ref={component=> this.courseLabel=component} /> 
						</View>
						<View style = {styles.leftHalf_lower}>
							<Text style={{fontSize:20}}>
								{"In session"}
							</Text>
							
							<View>
								<TextInput style={{height:20, width:150, fontSize:20}} value = 'Location Label' editable={false} ref={component=> this.locationLabel=component} /> 
							</View>
							
							<Text style={{fontSize:20}}>
									1 More Class Today
							</Text>	
						</View>
					</View>
					<View style={styles.rightHalf}>
						<ListView
							enableEmptySections={true}
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
		aspectRatio: 1.6,
		padding: '2.5%', 
		flexDirection:'row', 
		flex:1, 
		justifyContent: 'center'
	},
	leftHalf: {
		flex: 6,
		// paddingTop: '2.5%',
		// paddingLeft: '2.5%',
		// paddingBottom: '2.5%',
		backgroundColor: '#F9E9FF',
	},
	leftHalf_upper: {
		height: '30%',
		padding: 0,
		backgroundColor: '#FFDEAD',
	},
	leftHalf_lower: {
		height: '70%',
		padding: 0,
		backgroundColor: '#98FB98',
	},
	rightHalf: {
		flex: 4,
		paddingLeft: '2.5%',
		// paddingRight: '2.5%',
		// paddingTop: '1%',
		// paddingBottom: '1%',
		backgroundColor: '#E6E6FA',
	},
	rightHalf_eachOfFourCards: { 
		// justifyContent: 'center', 
		// marginTop: '5%',
		marginBottom: '5%',
		borderColor: COLOR_BLACK, 
		borderWidth: 1, 
		borderRadius: 1,
		paddingTop: '3%',
		paddingLeft: '3%',
		overflow: 'hidden',
		// flex: 1, 
		width: '100%', 
		aspectRatio: 2.85,
		flexDirection: 'row',
		backgroundColor: '#FFC0CB',
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
	sc_courseText: { fontSize: 24, color: COLOR_VDGREY, /*paddingBottom: 2 */},
	sc_subText: { fontSize: 16, color: COLOR_VDGREY, paddingBottom: 2},
	sc_timeText: { fontSize: 12, color: COLOR_VDGREY },
});

// Holds the view for an individual section/class 
var DayItem = ({ data }) => (
	<TouchableHighlight onPress= {
		()=>{this.courseLabel.setNativeProps({text: data.subject_code + ' ' + data.course_code})
		this.timeLabel.setNativeProps({text: data.day_code + ' ' + data.time_string}) 
		this.locationLabel.setNativeProps({text: data.building + ' ' + data.room}) }
		}> 
		<View style={styles.rightHalf_eachOfFourCards}>
			<View style={{flex:6, flexDirection: 'column', justifyContent: 'flex-end'}}>
				<Text style={styles.sc_timeText}>
					{data.day_code + ' ' + data.time_string}
				</Text>
				<Text
					style={styles.sc_courseText}
					numberOfLines={1}
				>
					{data.subject_code + ' ' + data.course_code}
				</Text>
			</View>
			<View style={{flex:1, flexDirection: 'column', justifyContent: 'flex-end', alignItems: 'flex-start'}}>
				<Text style={[styles.sc_subText]} numberOfLines={1}>
					{data.meeting_type === 'Lecture' && 'LE'}
					{data.meeting_type === 'Discussion' && 'DI'}
					{/*data.meeting_type/* + ' ' + data.time_string + '\n' */}
					{/* {data.instructor_name + '\n'}
					{data.building + data.room} */}
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
