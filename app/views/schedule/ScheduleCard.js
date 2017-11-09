import React from 'react';
import {
	View,
	Text,
	ListView
} from 'react-native';
import { getData } from './scheduleData';
import ScrollCard from '../card/ScrollCard';
import logger from '../../util/logger';
import css from '../../styles/css';

var scheduleData = getData();
var dataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

var ScheduleCard = () => {
	logger.ga('Card Mounted: Class Schedule');

	return (
		<ScrollCard
			id='schedule'
			title='Class Schedule'
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

export default ScheduleCard;
