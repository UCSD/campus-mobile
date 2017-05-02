import React from 'react';
import {
	View,
	Text,
	ListView,
	StyleSheet,
	TouchableOpacity,
	Dimensions
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import moment from 'moment';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

import logger from '../../util/logger';

const dataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2,
	sectionHeaderHasChanged: (s1, s2) => s1 !== s2
});

const ConferenceListView = ({ style, scrollEnabled, rows, personal, disabled, conferenceData, saved, addConference, removeConference }) => (
	<ListView
		style={style}
		contentContainerStyle={{ alignItems: 'center', justifyContent: 'center' }}
		scrollEnabled={scrollEnabled}
		stickySectionHeadersEnabled={false}
		dataSource={dataSource.cloneWithRowsAndSections(convertArrayToMap(adjustData(conferenceData.schedule, saved, personal, rows)))}
		renderRow={(rowData, sectionID, rowID, highlightRow) => {
			// Don't render first row bc rendered by header
			if (Number(rowID) !== 0) {
				return (
					<View style={styles.rowContainer}>
						<EmptyItem />
						<ConferenceItem
							conferenceData={rowData}
							saved={isSaved(saved, rowData.id)}
							add={addConference}
							remove={removeConference}
							disabled={disabled}
						/>
					</View>
				);
			} else {
				return null;
			}
		}}
		renderSectionHeader={(sectionData, sectionID) => (
			// Render header along with first row
			<View style={styles.rowContainer}>
				<ConferenceHeader
					timestamp={sectionID}
				/>
				<ConferenceItem
					conferenceData={sectionData[0]}
					saved={isSaved(saved, sectionData[0].id)}
					add={addConference}
					remove={removeConference}
					disabled={disabled}
				/>
			</View>
		)}
	/>
);

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

function convertArrayToMap(scheduleArray, header = false) {
	const scheduleMap = {};

	Object.keys(scheduleArray).forEach((key) => {
		const session = scheduleArray[key];
		if (!scheduleMap[session['time-start']]) {
			// Create an entry in the map for the timestamp if it hasn't yet been created
			scheduleMap[session['time-start']] = [];
		}
		scheduleMap[session['time-start']].push(session);
	});

	// Remove an item from section so spacing lines up
	if (header) {
		Object.keys(scheduleMap).forEach((key) => {
			scheduleMap[key].pop();
		});
	}
	return scheduleMap;
}

const ConferenceItem = ({ conferenceData, saved, add, remove, disabled }) => (
	<View
		style={styles.row}
	>
		<TouchableOpacity
			style={styles.titleContainer}
			onPress={() => Actions.ConferenceDetailView({ data: conferenceData })}
		>
			<Text
				style={styles.titleText}
				numberOfLines={2}
			>
				{conferenceData['talk-title']}
			</Text>
		</TouchableOpacity>
		{ (disabled) ? (null) : (
			<TouchableOpacity
				style={styles.starButton}
				onPress={
					() => ((saved) ? (remove(conferenceData.id)) : (add(conferenceData.id)))
				}
			>
				<Icon
					name={ saved ? 'star' : 'star-border' }
					size={28}
					color={ saved ? 'yellow' : 'grey' }
				/>
			</TouchableOpacity>
		) }
	</View>
);

const EmptyItem = () => (
	<View style={styles.emptyRow} />
);

const ConferenceHeader = ({ timestamp }) => (
	<View
		style={styles.header}
	>
		<Text>
			{moment(Number(timestamp)).format('MMM Do')}
		</Text>
		<Text>
			{moment(Number(timestamp)).format('h:mm a')}
		</Text>
	</View>
);

const mapStateToProps = (state) => (
	{
		conferenceData: state.conference.data,
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
	header: { height: 50, flex: 1, paddingLeft: 7, paddingTop: 7, backgroundColor: '#DDD', borderBottomWidth: 1, borderColor: '#FFF' },
	rowContainer: { flex: 1, flexDirection: 'row' },
	emptyRow: { flex: 1, flexDirection: 'row', height: 50, backgroundColor: '#FFFFFF', borderBottomWidth: 1, borderColor: '#FFF' },
	row: { flex: 3, flexDirection: 'row', height: 50, backgroundColor: '#FFFFFF', borderBottomWidth: 1, borderColor: '#DDD' },
	titleContainer: { flex: 1, padding: 7, justifyContent: 'center' },
	titleText: {},
	starButton: { height: 50, width: 50, justifyContent: 'center', alignItems: 'center' }
});

export default ActualConferenceListView;
