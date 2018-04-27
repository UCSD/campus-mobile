import React from 'react';
import {
	View,
	Text,
	StyleSheet,
	ListView
} from 'react-native';

import { getData } from './scheduleData';
import ScrollCard from '../card/ScrollCard';
import logger from '../../util/logger';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';
import {
	COLOR_LGREY,
	COLOR_DGREY
} from '../../styles/ColorConstants';

const scheduleData = getData();
const daytaSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ScheduleCard = () => {
	logger.ga('Card Mounted: Schedule');

	return (
		<ScrollCard
			id="Schedule"
			title="Schedule"
			scrollData={scheduleData}
			renderRow={
				(rowData, sectionID, rowID, highlightRow) => (
					(rowID !== 'SA' && rowID !== 'SU') ? (
						<ScheduleDay
							id={rowID}
							data={rowData}
						/>
					) : (null)
			)}
			actionButton={null}
			extraActions={null}
			updateScroll={null}
			lastScroll={null}
		/>
	);
};

const ScheduleDay = ({ id, data }) => (
	<View
		style={styles.dayContainer}
	>
		<Text
			style={styles.dayText}
		>
			{id}
		</Text>
		<DayList
			courseItems={data}
		/>
	</View>
);

const DayList = ({ courseItems }) => (
	<ListView
		dataSource={daytaSource.cloneWithRows(courseItems)}
		renderRow={(rowData, sectionID, rowID, highlightRow) => (
			<DayItem
				key={rowID}
				data={rowData}
			/>
		)}
		renderSeparator={(sectionID, rowID, adjacentRowHighlighted) => (
			<DaySpacer
				key={'spacer' + rowID}
			/>
		)}
	/>
);

/*
	{
		building: currData.building,
		room: currData.room,
		instructor_name: currData.instructor_name,
		section: currData.section,
		subject_code: currCourse.subject_code,
		course_code: currCourse.course_code,
		course_title: currCourse.course_title,
		time_string,
		start_time: startSeconds,
		end_time: endSeconds,
		meeting_type: currData.meeting_type,
		special_mtg_code
	}
 */
const DayItem = ({ data }) => (
	<View
		style={styles.dayRow}
	>
		<Text
			style={styles.courseText}
			numberOfLines={1}
		>
			{data.course_title}
		</Text>
		<Text
			style={styles.subText}
		>
			{data.meeting_type + ' ' + data.time_string + '\n'}
			{data.instructor_name + '\n'}
			{data.building + data.room}
		</Text>
	</View>
);

const DaySpacer = () => (
	<View
		style={styles.spacer}
	/>
);

const styles = StyleSheet.create({
	spacer: { height: 1, width: MAX_CARD_WIDTH, backgroundColor: COLOR_LGREY },
	dayText: { fontSize: 18, color: COLOR_DGREY },
	courseText: { fontSize: 18, color: COLOR_DGREY },
	subText: { fontSize: 13, color: COLOR_DGREY, opacity: 0.69 },
	dayContainer: { width: MAX_CARD_WIDTH + 2, padding: 7 },
	dayRow: { height: 70, justifyContent: 'center' },
});

export default ScheduleCard;
