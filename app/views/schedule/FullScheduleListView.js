import React from 'react';
import {
	ListView,
	View,
	Text,
	StyleSheet,
} from 'react-native';
import { connect } from 'react-redux';
import logger from '../../util/logger';
import schedule from '../../util/schedule';
import { NAVIGATOR_HEIGHT } from '../../styles/LayoutConstants';

const rowHasChanged = (r1, r2) => r1.id !== r2.id;
const sectionHeaderHasChanged = (s1, s2) => s1 !== s2;
const ds = new ListView.DataSource({ rowHasChanged, sectionHeaderHasChanged });

class FullSchedule extends React.Component {
	constructor(props) {
		super();
		this.state = {
			dataSource: ds.cloneWithRowsAndSections(schedule.getData(props.fullScheduleData))
		};
	}

	componentDidMount() {
		logger.ga('Card Mounted: Full Schedule');
	}

	renderRow = (rowData, sectionId) => (
		<IndividualClass key={sectionId} data={rowData} />
	)

	renderSectionHeader = (sectionRows, sectionId) => {
		const day = schedule.dayOfWeekInterpreter(sectionId);
		if (day === 'Saturday' || day === 'Sunday') {
			return null;
		}
		return (
			<View style={styles.header_wrapper}>
				<Text style={styles.header_text}>
					{day}
				</Text>
			</View>
		);
	}

	render() {
		return (
			// TODO: CONVERT TO SECTIONLIST
			<ListView
				style={styles.container}
				dataSource={this.state.dataSource}
				renderRow={this.renderRow}
				renderSectionHeader={this.renderSectionHeader}
				stickySectionHeadersEnabled={true}
				enableEmptySections={true}
			/>
		);
	}
}

const IndividualClass = ({ data }) => (
	<View style={styles.row}>
		<Text style={styles.course_code}>
			{data.subject_code} {data.course_code}
		</Text>
		<Text
			style={styles.course_title}
			numberOfLines={1}
		>
			{data.course_title}
		</Text>
		<Text style={styles.course_text}>
			{data.meeting_type} {data.time_string + '\n'}
			{data.instructor_name + '\n'}
			{data.building + data.room}
		</Text>
	</View>
);

const styles = StyleSheet.create({
	// row: {
	//   padding: 15,
	//   marginBottom: 5,
	//   backgroundColor: 'skyblue',
	// },
	container: {
		flexGrow: 1,
		marginTop: NAVIGATOR_HEIGHT - 1,
	},
	header_wrapper: {
		// marginTop: 10,
		marginBottom: 20,
		borderColor: '#CCC',
		borderTopWidth:1,
		borderBottomWidth:1,
		backgroundColor: '#FFFFFF'
	},
	header_text: {
		marginTop: 15,
		marginBottom: 15,
		marginLeft: 25,
		fontWeight: 'bold',
		fontSize: 22,
	},
	row: {
		// paddingTop: 20,
		paddingBottom: 20,
		paddingLeft: 25,
	},
	course_code: {
		fontSize: 18,
		fontWeight: 'bold',
		color: '#000000',
	},
	course_title: {
		fontSize: 18,
		color: '#000000',
		marginBottom: 4,
	},
	course_text: {
		fontSize: 16,
		color: '#000000',
	},
	// main_full: { flexGrow: 1, marginTop: NAVIGATOR_HEIGHT },
	// sc_dayText: { fontSize: 16, color: COLOR_BLACK, paddingBottom: 6 }, //2
	// sc_courseText: { fontSize: 14, color: COLOR_BLACK, paddingBottom: 2 },
	// sc_subText: { fontSize: 13, color: COLOR_VDGREY },
	// sc_dayContainer: { width: MAX_CARD_WIDTH + 2, padding: 7, flexDirection: 'row', flex:1 }, //1
	// sc_fullScheduleContainer: { width: MAX_CARD_WIDTH + 2, padding: 7, flexDirection: 'column', flex:1 },
	// sc_dayRow: { justifyContent: 'center', paddingBottom: 10, borderColor: '#CCC', borderWidth:1, },
	// sc_scheduleContainer: {width: MAX_CARD_WIDTH + 2, padding: 7, flexDirection:'column', flex:1 },
});

function mapStateToProps(state) {
	return {
		fullScheduleData: state.schedule.data,
	};
}

const FullScheduleListView = connect(mapStateToProps)(FullSchedule);

export default FullScheduleListView;
