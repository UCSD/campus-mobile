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

// var scheduleData = getClasses();
var dataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ScheduleCard = ({ scheduleData, actionButton }) => (
	<Card id="schedule" title="Upcoming Classes" >
		{scheduleData ? (
			<View style={styles.sc_scheduleCard}>
				<View style={styles.sc_scheduleContainer}>
					{/* <TouchableHighlight style={styles.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={() => general.gotoNavigationApp(data.coords.lat, data.coords.lon)}>
						<View style={css.dl_dir_traveltype_container}>
							<Icon name="md-walk" size={32} color={COLOR_SECONDARY} />
						</View>
					</TouchableHighlight> */}
					<View style = {{flex: 6, alignItems: 'flex-start', }}>
						<View>
							<TextInput style={{height:20, width:150, fontSize:20, fontWeight:'bold', color: COLOR_VDGREY }} value={'Class Time Label'} /> 
							<TextInput style={{height:20, width:150, fontSize:20, fontWeight:'bold'}} value ={'Course Label'} editable={false} ref={component=> this.courseLabel=component} /> 
						</View>
						
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
					<View style={{flex: 4}}>
						<ListView
							dataSource={dataSource.cloneWithRows(scheduleData)}
							renderRow={(rowData, sectionID, rowID, highlightRow) => (
								(rowID !== 'SA' && rowID !== 'SU') ? (
								<ScheduleDay
									id={rowID}
									data={rowData}
								/>
								) : (null)
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

// Holds the the daylist listview (currently only used as a container for the listview)
var ScheduleDay = ({ id, data }) => (
	// <View style={css.sc_dayContainer}>
	<View style={styles.scheduleList}>
		<DayList
			courseItems={data} />
	</View>
);

// Holds the listview for a day of the week
var DayList = ({ courseItems }) => (
	<ListView
		style={styles.dayListStyle}
		dataSource={dataSource.cloneWithRows(courseItems)}
		renderRow={(rowData, sectionID, rowID, highlightRow) => (

			<DayItem key={rowID} data={rowData} />
		)}
	/>
);

// Holds the view for an individual section/class 
var DayItem = ({ data }) => (
	<TouchableHighlight onPress= {
		()=>{this.courseLabel.setNativeProps({text: data.subject_code + ' ' + data.course_code})
		this.timeLabel.setNativeProps({text: data.day_code + ' ' + data.time_string}) 
		this.locationLabel.setNativeProps({text: data.building + ' ' + data.room}) }
		}> 
		<View style={styles.sc_dayRow}>
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

const styles = StyleSheet.create({
	more: { alignItems: 'center', justifyContent: 'center', padding: 6 },
	more_label: { fontSize: 20, color: COLOR_PRIMARY, fontWeight: '300' },
	specialEventsListView: { borderBottomWidth: 1, borderBottomColor: COLOR_MGREY },
	nextClassContainer: { flexGrow: 1, width: MAX_CARD_WIDTH },
	contentContainer: { flexShrink: 1, width: MAX_CARD_WIDTH },
	fullScheduleButton: { width: MAX_CARD_WIDTH, backgroundColor: COLOR_LGREY, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingVertical: 8, borderTopWidth: 1, borderBottomWidth: 1, borderColor: COLOR_MGREY },
	loadingContainer: { alignItems: 'center', justifyContent: 'center', width: MAX_CARD_WIDTH },
	scheduleList: { flex: 1, justifyContent: 'flex-end', alignItems: 'flex-end'},
	sc_dayRow: { justifyContent: 'center', padding: 3, borderColor: COLOR_BLACK, borderWidth: 1, flex: 1, width: '100%', flexDirection: 'row'},
	dayListStyle: {flex: 1, paddingRight: 10 /* align0 Items:'flex-end'*/},
	sc_scheduleContainer: { width: MAX_CARD_WIDTH, padding: 10, flexDirection:'row', flex:1, justifyContent: 'center'},
	sc_scheduleCard: { width: MAX_CARD_WIDTH + 2, padding: 7, flexDirection:'column', flex: 1},
	sc_dayText: { fontSize: 16, color: COLOR_BLACK, /*paddingBottom: 6 */},
	dc_locations_row_right: { flex: 6 },
	sc_courseText: { fontSize: 24, color: COLOR_VDGREY, /*paddingBottom: 2 */},
	sc_subText: { fontSize: 16, color: COLOR_VDGREY, paddingBottom: 2},
	sc_timeText: { fontSize: 12, color: COLOR_VDGREY },
});

export default ScheduleCard;
