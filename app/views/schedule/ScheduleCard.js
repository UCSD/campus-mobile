import React, { PropTypes } from 'react';
import {
	View,
	Text,
	ListView,
	StyleSheet,
	TouchableHighlight,
	ActivityIndicator,
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
} from '../../styles/ColorConstants';
import {
	MAX_CARD_WIDTH,
} from '../../styles/LayoutConstants';

// var scheduleData = getClasses();
var dataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ScheduleCard = ({ scheduleData, actionButton }) => (
	<Card id="schedule" title="Class Schedule">
		{scheduleData ? (
			<View style={styles.sc_scheduleContainer}>
				<ListView
					style={{flex:1}}
					dataSource={dataSource.cloneWithRows(scheduleData)}
					renderRow={(rowData, sectionID, rowID, highlightRow) => (
						<ScheduleDay
							id={rowID}
							data={rowData}
						/>
					)}
				/>
				<TouchableHighlight style={[css.dc_locations_row_right, {flex:1}]} underlayColor={'rgba(200,200,200,.1)'} onPress={() => general.gotoNavigationApp(data.coords.lat, data.coords.lon)}>
					<View style={css.dl_dir_traveltype_container}>
						<Icon name="md-walk" size={32} color={COLOR_SECONDARY} />
					</View>
				</TouchableHighlight>
				{actionButton}
			</View>
		) : (
			<View style={styles.loadingContainer}>
				<ActivityIndicator size="large" />
			</View>
		)}
	</Card>
);

var ScheduleDay = ({ id, data }) => (
	// <View style={css.sc_dayContainer}>
	<View style={styles.scheduleList}>
		<Text style={styles.sc_dayText}>
			{/* {id} */}
		</Text>
		<DayList
			style={styles.dayListStyle} 
			courseItems={data} />
	</View>
);

var DayList = ({ courseItems }) => (
	<ListView
		// style={styles.dayListStyle}
		dataSource={dataSource.cloneWithRows(courseItems)}
		renderRow={(rowData, sectionID, rowID, highlightRow) => (
			<DayItem key={rowID} data={rowData} />
		)}
	/>
);

var DayItem = ({ data }) => (
	// <View style = {styles.scheduleList}>
	<View style={styles.sc_dayRow}>
		<Text
			style={[css.sc_courseText]}
			numberOfLines={1}
		>
			{data.course_title}
		</Text>
		<Text style={[css.sc_subText]}>
			{data.meeting_type + ' ' + data.time_string + '\n'}
			{data.instructor_name + '\n'}
			{data.building + data.room}
		</Text>
	</View>
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
	scheduleList: {flex: 1, justifyContent: 'flex-end', alignItems: 'flex-end'},
	sc_dayRow: {justifyContent: 'flex-end', padding: 5, borderColor: '#000', borderWidth:1, flex: 1, width: '65%'},
	dayListStyle: {alignItems:'flex-end'},
	sc_scheduleContainer: {width: MAX_CARD_WIDTH + 2, padding: 7, flexDirection:'column', flex:1 },
	sc_dayText: { fontSize: 16, color:'#000' /*COLOR_BLACK, /*paddingBottom: 6 */}
});

export default ScheduleCard;
