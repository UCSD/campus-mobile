import React from 'react';
import {
	View,
	Text,
	ListView,
	StyleSheet,
} from 'react-native';
import { getFinals } from './scheduleData';
import Card from '../card/Card';
import logger from '../../util/logger';
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

var scheduleData = getFinals();
var dataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

var FinalsCard = () => {
	logger.ga('Card Mounted: Finals Schedule');
	console.log(scheduleData['MO'].length);
	return (
        <Card
            id='finals'
            title='Finals Schedule'>
            <ListView
                dataSource={dataSource.cloneWithRows(scheduleData)}
                renderRow={(rowData, sectionID, rowID, highlightRow) => (
				<View>
					{ scheduleData[String(rowID)].length > 0 ? (
					<ScheduleDay
                    id={rowID}
                    data={rowData}
				/>) : null}
				</View>
                )}
            />
        </Card>
	);
};

var ScheduleDay = ({ id, data }) => (
	<View style={css.sc_fullScheduleContainer}>
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
			<DayItem key={rowID} data={rowData}/>
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

const styles = StyleSheet.create({
	more: { alignItems: 'center', justifyContent: 'center', padding: 6 },
	more_label: { fontSize: 20, color: COLOR_PRIMARY, fontWeight: '300' },
	specialEventsListView: { borderBottomWidth: 1, borderBottomColor: COLOR_MGREY },
	nextClassContainer: { flexGrow: 1, width: MAX_CARD_WIDTH },
	contentContainer: { flexShrink: 1, width: MAX_CARD_WIDTH }
});

export default FinalsCard;
