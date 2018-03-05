import React, { PropTypes } from 'react';
import {
	ListView,
	View,
	Text,
	StyleSheet,
} from 'react-native';
import moment from 'moment';
import { connect } from 'react-redux';
import css from '../../styles/css';
import logger from '../../util/logger';
import { getClasses } from './scheduleData';

const data = getClasses();

const rowHasChanged = (r1, r2) => r1.id !== r2.id
const sectionHeaderHasChanged = (s1, s2) => s1 !== s2
const ds = new ListView.DataSource({rowHasChanged, sectionHeaderHasChanged})

class FullSchedule extends React.Component {
	componentDidMount() {
		logger.ga('Card Mounted: Full Schedule');
	}

	state = {
		dataSource: ds.cloneWithRowsAndSections(data)
	}
	
	renderRow = (rowData, sectionId) => {
		return (
			<IndividualClass key={sectionId} data={rowData} />
		)
	}
	
	dayOfWeekIntepreter = (abbr) => {
		fullString = '';
		switch(abbr) {
			case 'MO':
				fullString = 'Monday';
				break;
			case 'TU':
				fullString = 'Tuesday';
				break;
			case 'WE':
				fullString = 'Wednesday';
				break;
			case 'TH':
				fullString = 'Thursday';
				break;
			case 'FR':
				fullString = 'Friday';
				break;
			case 'SA':
				fullString = 'Saturday';
				break;
			case 'SU':
				fullString = 'Sunday';
				break;				
			default:
				fullString = abbr;
		}
		return fullString;
	}

	renderSectionHeader = (sectionRows, sectionId) => {
		let day = this.dayOfWeekIntepreter(sectionId);
		return (
		  <Text style={styles.header}>
			{day}
		  </Text>
		)
	}

	render () {
		return (
			<ListView
				style={css.main_full}
				dataSource={this.state.dataSource}
				renderRow={this.renderRow}
				renderSectionHeader={this.renderSectionHeader}
			/>
		);
	}
}

const styles = StyleSheet.create({
	container: {
	  flex: 1,
	},//not used
	// row: {
	//   padding: 15,
	//   marginBottom: 5,
	//   backgroundColor: 'skyblue',
	// },
	header: {
	  padding: 15,
	//   marginBottom: 5,
	//   backgroundColor: 'steelblue',
	//   color: 'white',
	  fontWeight: 'bold',
	  fontSize: 16,
	  borderColor: '#CCC', 
	  borderTopWidth:1,
	  borderBottomWidth:1,
	},
	row_container: { 
		// justifyContent: 'center', 
		padding: 10, 
		paddingLeft: 15,
	},
	course_title: {
		fontSize: 14, 
		fontWeight: 'bold',
		color: '#000000',
	}
	// main_full: { flexGrow: 1, marginTop: NAVIGATOR_HEIGHT },
	// sc_dayText: { fontSize: 16, color: COLOR_BLACK, paddingBottom: 6 }, //2
	// sc_courseText: { fontSize: 14, color: COLOR_BLACK, paddingBottom: 2 },
	// sc_subText: { fontSize: 13, color: COLOR_VDGREY },
	// sc_dayContainer: { width: MAX_CARD_WIDTH + 2, padding: 7, flexDirection: 'row', flex:1 }, //1
	// sc_fullScheduleContainer: { width: MAX_CARD_WIDTH + 2, padding: 7, flexDirection: 'column', flex:1 },
	// sc_dayRow: { justifyContent: 'center', paddingBottom: 10, borderColor: '#CCC', borderWidth:1, },
	// sc_scheduleContainer: {width: MAX_CARD_WIDTH + 2, padding: 7, flexDirection:'column', flex:1 },
})

const IndividualClass = ({ data }) => (
	<View style={styles.row_container}>
		<Text style={styles.course_title}>
			{data.subject_code} {data.course_code} 
		</Text>
		<Text
			style={css.sc_courseText}
			numberOfLines={1}
		>
			{data.course_title}
		</Text>
		<Text style={css.sc_subText}>
			{data.meeting_type} {data.time_string + '\n'}
			{data.instructor_name + '\n'}
			{data.building + data.room}
		</Text>
	</View>
);

function mapStateToProps(state) {
	return {
		fullScheduleData: state.schedule.data,
	};
}

const FullScheduleListView = connect(
	mapStateToProps
)(FullSchedule);

export default FullScheduleListView;
