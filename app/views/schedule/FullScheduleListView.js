import React, { PropTypes } from 'react';
import {
	ListView,
	View,
	Text,
} from 'react-native';

import css from '../../styles/css';


const dataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
var scheduleData = getData();

const FullScheduleListView = ({ style, data, rows, scrollEnabled, item, card }) => {
	return (
		<ListView
			style={style}
			scrollEnabled={scrollEnabled}
			dataSource={dataSource.cloneWithRows((rows) ? (data.slice(0,rows)) : (data))}
			renderRow={(rowData, sectionID, rowID, highlightRow) => {
				<ScheduleDay
					id={rowID}
					data={rowData}
				/>
			}}
		/>
)};

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
			{data.time_string + '\n'}
			{data.building + data.room}
		</Text>
	</View>
);

FullScheduleListView.propTypes = {
	style: PropTypes.number, // Stylesheet is a number for some reason?
	data: PropTypes.array.isRequired,
	rows: PropTypes.number,
	scrollEnabled: PropTypes.bool,
	item: PropTypes.string.isRequired,
	card: PropTypes.bool,
};

FullScheduleListView.defaultProps = {
	scrollEnabled: false,
	card: false
};

export default FullScheduleListView;
