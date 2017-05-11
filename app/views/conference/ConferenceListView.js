import React from 'react';
import {
	View,
	Text,
	ListView,
	StyleSheet,
} from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import moment from 'moment';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';
import Touchable from '../common/Touchable';
import { getMaxCardWidth, getScreenWidth, getScreenHeight, platformIOS, getHumanizedDuration } from '../../util/general';

const dataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2,
	sectionHeaderHasChanged: (s1, s2) => s1 !== s2
});

const ConferenceListView = ({ style, scrollEnabled, rows, personal, disabled, conferenceData, saved, addConference, removeConference }) => {
	if (personal && saved && saved.length === 0) {
		return (
			<View style={[style, rows ? styles.cardWidth : styles.fullWidth]}>
				<Text style={styles.noSavedSessions}>
					Click the star icon next to a session to save it to your list.
				</Text>
			</View>
		);
	} else {
		return (
			<ListView
				style={[style, rows ? styles.cardWidth : styles.fullWidth]}
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
	}
}

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
		if (!scheduleMap[session['start-time']]) {
			// Create an entry in the map for the timestamp if it hasn't yet been created
			scheduleMap[session['start-time']] = [];
		}
		scheduleMap[session['start-time']].push(session);
	});

	// Remove an item from section so spacing lines up
	if (header) {
		Object.keys(scheduleMap).forEach((key) => {
			scheduleMap[key].pop();
		});
	}
	return scheduleMap;
}

const ConferenceItem = ({ conferenceData, saved, add, remove, disabled }) => {
	return (
		<View
			style={styles.itemRow}
		>
			<CircleBorder />
			
			<View style={styles.titleContainer}>
				<Touchable
					onPress={() => Actions.ConferenceDetailView({ data: conferenceData })}
				>
					<View>
						{conferenceData['talk-title'] ? (
							<Text
								style={styles.titleText}
								numberOfLines={2}
							>
								{conferenceData['talk-title']}
							</Text>
						) : null }

						<Text style={styles.labelText}>
							{ conferenceData.label ? (
								<Text>{conferenceData.label} - </Text>
							) : null }
							{ conferenceData['talk-type'] === 'Keynote' ? (
								<Text>{conferenceData['talk-type']} - </Text>
							) : null }
							{getHumanizedDuration(conferenceData['start-time'], conferenceData['end-time'])}
						</Text>
					</View>
				</Touchable>
			</View>

			{ (!disabled) ? (
				<View style={styles.starButton}>
					<Touchable
						onPress={
							() => ((saved) ? (remove(conferenceData.id)) : (add(conferenceData.id)))
						}
					>
						<View style={styles.starButtonInner}>
							<Icon
								name={ 'ios-star-outline'}
								size={32}
								color={'#999'}
								style={styles.starOuterIcon}
							/>
							{ saved ? (
								<Icon
									name={ 'ios-star'}
									size={26}
									color={'yellow'}
									style={styles.starInnerIcon}
								/>
							) : null }
						</View>
					</Touchable>
				</View>
			) : null }
		</View>
	);
}

const EmptyItem = () => (
	<View style={styles.emptyRow} />
);

const ConferenceHeader = ({ timestamp }) => (
	<View
		style={styles.header}
	>
		<Text style={styles.headerText}>
			{moment(Number(timestamp)).format('h:mm')}
		</Text>
	</View>
);

const CircleBorder = () => (
	<View style={styles.borderContainer}>
		<View style={styles.line} />
		<View style={styles.circle} />
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

const NavigatorIOSHeight = 58,
	  NavigatorAndroidHeight = 44,
	  TabBarHeight = 40;

const styles = StyleSheet.create({
	rowContainer: { flexDirection: 'row', height: 70 },
	fullWidth: { width: getScreenWidth() },
	cardWidth: { width: getMaxCardWidth() },
	itemRow: { flexGrow: 1, flexDirection: 'row', backgroundColor: '#F9F9F9' },
	header: { justifyContent: 'flex-start', alignItems: 'center', width: 45, backgroundColor: '#F9F9F9', borderBottomWidth: 1, borderColor: '#F9F9F9' },
	headerText: { textAlign: 'right', alignSelf: 'stretch', color: '#000', fontSize: 12, marginTop: 7 },
	emptyRow: { width: 45, flexDirection: 'row',  backgroundColor: '#F9F9F9', borderBottomWidth: 1, borderColor: '#F9F9F9' },
	titleContainer: { flex: 1, marginTop: 3 },
	titleText: { alignSelf: 'stretch', fontSize: 18, color: '#000' },
	labelText: { fontSize: 13, paddingTop: 4 },

	starButton: { width: 50,  },
	starButtonInner: { justifyContent: 'flex-start', alignItems: 'center' },
	starOuterIcon: { position: platformIOS() ? 'absolute' : 'relative', zIndex: 10, backgroundColor: 'rgba(0,0,0,0)' },
	starInnerIcon: { position: 'absolute', zIndex: platformIOS() ? 5 : 15, marginTop: 3 },

	borderContainer: { width: 1, alignSelf: 'stretch', marginHorizontal: 20, alignItems: 'flex-start' },
	line: { flexGrow: 1, borderLeftWidth: 1, borderColor: '#AAA', paddingBottom: 20 },
	circle: { position: 'absolute', top: 11, left: -2.5, height: 6, width: 6, borderRadius: 3, borderWidth: 1, borderColor: '#AAA', backgroundColor: '#F9F9F9' },
	bottomBorder: { borderBottomWidth: 1, borderBottomColor: '#DDD' },
	noSavedSessions: { fontSize: 18, textAlign: 'center', padding: 40, lineHeight: 30 },
});

export default ActualConferenceListView;
