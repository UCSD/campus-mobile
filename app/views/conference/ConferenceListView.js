import React from 'react';
import {
	View,
	Text,
	ListView,
	StyleSheet,
	TouchableOpacity
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import moment from 'moment';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

import logger from '../../util/logger';
import css from '../../styles/css';

const dataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2,
	sectionHeaderHasChanged: (s1, s2) => s1 !== s2
});

const ConferenceListView = ({ style, scrollEnabled, rows, personal, scheduleData, saved, addConference, removeConference }) => {
	return (
		<ListView
			style={style}
			scrollEnabled={scrollEnabled}
			dataSource={dataSource.cloneWithRowsAndSections(convertArrayToMap(adjustData(scheduleData, saved, personal, rows)))}
			renderRow={(rowData, sectionID, rowID, highlightRow) => (
				<ConferenceItem
					conferenceData={rowData}
					saved={isSaved(saved, rowData.id)}
					add={addConference}
					remove={removeConference}
				/>
			)}
			renderSectionHeader={(sectionData, sectionID) => (
				<ConferenceHeader
					timestamp={sectionID}
				/>
			)}
		/>
	);
};

function adjustData(scheduleArray, savedArray, personal, rows) {
	// Filter out saved items
	if (!personal || !savedArray) {
		if (!rows) {
			return scheduleArray;
		} else {
			const trimmed = {};
			const keys = Object.keys(scheduleArray);

			for (let i = 0; i < rows; ++i) {
				trimmed[keys[i]] = scheduleArray[keys[i]];
			}
			return trimmed;
		}
	} else {
		const filtered = {};

		if (rows) {
			for (let i = 0; i < savedArray.length && i < rows; ++i) {
				const key = savedArray[i];
				filtered[key] = scheduleArray[key];
			}
		} else {
			for (let i = 0; i < savedArray.length; ++i) {
				const key = savedArray[i];
				filtered[key] = scheduleArray[key];
			}
		}
		return filtered;
	}
}

function isSaved(savedArray, id) {
	for ( let i = 0; i < savedArray.length; ++i) {
		if (savedArray[i] === id) {
			return true;
		}
	}
	return false;
}

function convertArrayToMap(scheduleArray) {
	const scheduleMap = {};

	Object.keys(scheduleArray).forEach((key) => {
		const session = scheduleArray[key];
		if (!scheduleMap[session['time-start']]) {
			// Create an entry in the map for the timestamp if it hasn't yet been created
			scheduleMap[session['time-start']] = [];
		}
		scheduleMap[session['time-start']].push(session);
	});
	return scheduleMap;
}

const ConferenceItem = ({ conferenceData, saved, add, remove }) => (
	<View
		style={styles.row}
	>
		<TouchableOpacity
			style={styles.titleContainer}
			onPress={() => Actions.ConferenceDetailView({ data: conferenceData })}
		>
			<Text
				style={styles.titleText}
			>
				{conferenceData['talk-title']}
			</Text>
		</TouchableOpacity>
		<TouchableOpacity
			style={styles.starButton}
			onPress={
				() => ((saved) ? (remove(conferenceData.id)) : (add(conferenceData.id)))
			}
		>
			<Icon
				name="star"
				size={28}
				color={(saved) ? 'yellow' : 'gray'}
			/>
		</TouchableOpacity>
	</View>
);

const ConferenceHeader = ({ timestamp }) => (
	<View
		style={styles.header}
	>
		<Text>
			{moment(Number(timestamp)).format('MMM Do YYYY, h:mm a')}
		</Text>
	</View>
);

const mapStateToProps = (state) => (
	{
		scheduleData: state.conference.data,
		saved: state.conference.saved
	}
);

const mapDispatchToProps = (dispatch) => (
	{
		addConference: (id) => {
			dispatch({ type: 'ADD_CONFERENCE', id });
		},
		removeConference: (id) => {
			dispatch({ type: 'REMOVE_CONFERENCE', id });
		}
	}
);

const ActualConferenceListView = connect(
	mapStateToProps,
	mapDispatchToProps
)(ConferenceListView);

const styles = StyleSheet.create({
	row: { flexDirection: 'row', height: 50, backgroundColor: '#FFFFFF', borderBottomWidth: 1, borderColor: '#DDD' },
	titleContainer: { flex: 1 },
	titleText: {},
	starButton: { height: 50, width: 50, justifyContent: 'center', alignItems: 'center' }
});

export default ActualConferenceListView;
