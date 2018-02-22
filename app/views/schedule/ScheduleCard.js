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
			<View style={css.sc_scheduleContainer}>
				<View style={css.sc_dayContainer}>
					<View
						style={css.sc_dayRow}>
						<Text
							style={css.sc_courseText}>
							CAT 125
						</Text>
						<Text
							style={css.sc_subText}>
							1:00 PM to 1:50 PM
						</Text>
						<Text
							style={css.sc_subText}>
							PCYNH 199
						</Text>
					</View>
					<TouchableHighlight style={css.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={() => general.gotoNavigationApp(data.coords.lat, data.coords.lon)}>
						<View style={css.dl_dir_traveltype_container}>
							<Icon name="md-walk" size={32} color={COLOR_SECONDARY} />
						</View>
					</TouchableHighlight>
					</View>
				<View style={css.sc_dayContainer}>
					<View
						style={css.sc_dayRow}>
						<Text style={css.sc_subText}>
							CSE 8A
						</Text>
						<Text style={css.sc_subText}>
							Lecture
						</Text>
						<Text style={css.sc_subText}>
							2PM
						</Text>
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
// var ScheduleCard = () => {
// 	logger.ga('Card Mounted: Class Schedule');

// 	return (
// 		<Card 
// 			id='schedule'
// 			title='Class Schedule'>
// 			<View style={css.sc_dayContainer}>
// 				<View
// 					style={css.sc_dayRow}>
// 					<Text
// 						style={css.sc_courseText}>
// 						CAT 125
// 					</Text>
// 					<Text
// 						style={css.sc_subText}>
// 						1:00 PM to 1:50 PM
// 					</Text>
// 					<Text
// 						style={css.sc_subText}>
// 						PCYNH 199
// 					</Text>
// 				</View>
// 				<TouchableHighlight style={css.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={() => general.gotoNavigationApp(data.coords.lat, data.coords.lon)}>
// 				<View style={css.dl_dir_traveltype_container}>
// 					<Icon name="md-walk" size={32} color={COLOR_SECONDARY} />
// 				</View>
// 			</TouchableHighlight>
// 			</View>
// 			<View style={css.sc_dayContainer}>
// 				<View
// 					style={css.sc_dayRow}>
// 					<Text style={css.sc_subText}>
// 						CSE 8A
// 					</Text>
// 					<Text style={css.sc_subText}>
// 						Lecture
// 					</Text>
// 					<Text style={css.sc_subText}>
// 						2PM
// 					</Text>
// 				</View>
// 			</View>
// 			<FullScheduleButton />
// 		</Card>

var ScheduleDay = ({ id, data }) => (
	<View style={css.sc_dayContainer}>
		<Text style={css.sc_dayText}>
			{id}
		</Text>
		<DayList courseItems={data} />
	</View>
);

var DayList = ({ courseItems }) => (
	<ListView
		dataSource={dataSource.cloneWithRows(courseItems)}
		renderRow={(rowData, sectionID, rowID, highlightRow) => (
			<DayItem key={rowID} data={rowData} />
		)}
	/>
);

var DayItem = ({ data }) => (
	<View style={css.sc_dayRow}>
		<Text
			style={css.sc_courseText}
			numberOfLines={1}
		>
			{data.course_title}
		</Text>
		<Text style={css.sc_subText}>
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
});

export default ScheduleCard;
