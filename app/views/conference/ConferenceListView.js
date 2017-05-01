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
import css from '../../styles/css';

const deviceWidth = Dimensions.get('window').width;

const dataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2,
	sectionHeaderHasChanged: (s1, s2) => s1 !== s2
});

// Side by listviews to simulate side headers...
const ConferenceListView = ({ style, scrollEnabled, rows, personal, disabled, scheduleData, saved, addConference, removeConference }) => (
	<View style={{ flex: 1, flexDirection: 'row' }}>
		<ListView
			style={style}
			ref={c => { this._headerList = c; }}
			scrollEnabled={false}
			showsVerticalScrollIndicator={false}
			dataSource={dataSource.cloneWithRowsAndSections(convertArrayToMap(adjustData(scheduleData, saved, personal, rows), true))}
			renderRow={(rowData, sectionID, rowID, highlightRow) => (
				<EmptyItem
					conferenceData={rowData}
					saved={isSaved(saved, rowData.id)}
					add={addConference}
					remove={removeConference}
					disabled={disabled}
				/>
			)}
			renderSectionHeader={(sectionData, sectionID) => (
				<ConferenceHeader
					timestamp={sectionID}
				/>
			)}
			enableEmptySections={true}
		/>
		<ListView
			style={style}
			contentContainerStyle={{ alignItems: 'center', justifyContent: 'center' }}
			scrollEnabled={scrollEnabled}
			dataSource={dataSource.cloneWithRowsAndSections(convertArrayToMap(adjustData(scheduleData, saved, personal, rows)))}
			renderRow={(rowData, sectionID, rowID, highlightRow) => (
				<ConferenceItem
					conferenceData={rowData}
					saved={isSaved(saved, rowData.id)}
					add={addConference}
					remove={removeConference}
					disabled={disabled}
				/>
			)}
			onScroll={(event) => {
				const scrollY = event.nativeEvent.contentOffset.y;
				this._headerList.scrollTo({ y: scrollY, animated: false });
			}}
		/>
	</View>
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
					name="star"
					size={28}
					color={(saved) ? 'yellow' : 'gray'}
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
	header: { maxWidth: 150, height: 50, flex: 1, padding: 7, backgroundColor: '#DDD', borderBottomWidth: 1, borderColor: '#FFF' },
	emptyRow: { maxWidth: 150, flexDirection: 'row', height: 50, backgroundColor: '#FFFFFF', borderBottomWidth: 1, borderColor: '#FFF' },
	row: { maxWidth: 500, alignSelf: 'flex-end', flexDirection: 'row', height: 50, backgroundColor: '#FFFFFF', borderBottomWidth: 1, borderColor: '#DDD' },
	titleContainer: { flex: 1, padding: 7, justifyContent: 'center' },
	titleText: {},
	starButton: { height: 50, width: 50, justifyContent: 'center', alignItems: 'center' }
});

export default ActualConferenceListView;
