import React from 'react';
import { View, Text, ListView, StyleSheet } from 'react-native';
import { connect } from 'react-redux';

import Card from '../card/Card';
import logger from '../../util/logger';
import schedule from '../../util/schedule';
import {
COLOR_VDGREY,
COLOR_DGREY,
} from '../../styles/ColorConstants';
import { MAX_CARD_WIDTH } from '../../styles/LayoutConstants';

const dataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2
});

const FinalsCard = ({ scheduleData }) => {
	logger.ga('Card Mounted: Finals Schedule');

	if (!scheduleData) {
		return null;
	}

	const parsedScheduleData = schedule.getData(scheduleData);
	const finalsData = schedule.getFinals(parsedScheduleData);

	// if (scheduleData.length > 0) {
	return (
		<Card id="finals" title="Finals Schedule">
			<ListView
				style={{ paddingTop: 0 }}
				enableEmptySections={true}
				dataSource={dataSource.cloneWithRows(finalsData)}
				renderSeparator={(sectionID, rowID, adjacentRowHighlighted) =>
					finalsData[rowID].length > 0 ? (
						<View
							style={{
								borderColor: "#EAEAEA",
								borderTopWidth: 1,
								width: MAX_CARD_WIDTH + 2
								// paddingBottom: 5,
							}}
							key={rowID}
						/>
					) : null
				}
				renderRow={(rowData, sectionID, rowID, highlightRow) => (
					<View>
						{finalsData[String(rowID)].length > 0 ? (
							<ScheduleDay id={rowID} data={rowData} />
						) : null}
					</View>
				)}
			/>
		</Card>
	);
	// } else {
	//   return (
	//     <Card id="finals" title="Finals Schedule">
	//       <View style={{
	//         flex:1,
	//         flexDirection: 'row',
	//         width: MAX_CARD_WIDTH,
	//         height: 60,
	//         alignItems: 'center',
	//         justifyContent: 'center'}}>
	//           <Text style={{
	//             textAlign:'center',
	//             fontSize: 16,
	//             fontWeight: "bold",
	//             color: COLOR_VDGREY}}>
	//             {"Congrats! You've finished all your finals!!"}
	//           </Text>
	//       </View>
	//     </Card>
	//   );
	// }
};

const ScheduleDay = ({ id, data }) => (
	<View style={styles.card_content}>
		<Text style={styles.day_of_week}>{schedule.dayOfWeekInterpreter(id)}</Text>
		<DayList courseItems={data} />
	</View>
);

const DayList = ({ courseItems }) => (
	<ListView
		dataSource={dataSource.cloneWithRows(courseItems)}
		renderRow={(rowData, sectionID, rowID, highlightRow) => (
			<DayItem key={rowID} data={rowData} />
		)}
	/>
);

const DayItem = ({ data }) => (
	<View style={styles.day_container}>
		<Text style={styles.course_title}>
			{data.subject_code} {data.course_code}
		</Text>
		<Text style={styles.course_text} numberOfLines={1}>
			{data.course_title}
		</Text>
		<Text style={styles.course_text}>
			{data.time_string + '\n'}
			{data.building + ' ' + data.room}
		</Text>
	</View>
);

const styles = StyleSheet.create({
	card_content: {
		width: MAX_CARD_WIDTH + 2,
		marginBottom: 10
	},
	day_of_week: {
		paddingTop: 10,
		paddingBottom: 5,
		paddingLeft: 15,
		fontWeight: 'bold',
		fontSize: 18,
		color: COLOR_VDGREY
	},
	day_container: {
		paddingLeft: 15,
		// justifyContent: 'center',
		paddingBottom: 5,
		paddingTop: 5
	},
	course_title: {
		fontSize: 16,
		fontWeight: 'bold',
		color: COLOR_VDGREY
	},
	course_text: {
		fontSize: 14,
		color: COLOR_DGREY
	}
});

const mapStateToProps = state => (
	{
		scheduleData: state.schedule.data,
	}
);

const ActualFinalsCard = connect(mapStateToProps)(FinalsCard);

export default ActualFinalsCard;
