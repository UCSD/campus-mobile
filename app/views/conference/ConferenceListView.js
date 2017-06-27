import React from 'react';
import {
	View,
	Text,
	ListView,
	StyleSheet,
} from 'react-native';
import { connect } from 'react-redux';

import {
	MAX_CARD_WIDTH,
	WINDOW_WIDTH,
	WINDOW_HEIGHT,
	NAVIGATOR_HEIGHT,
	TAB_BAR_HEIGHT,
} from '../../styles/LayoutConstants';
import {
	COLOR_LGREY,
	COLOR_BLACK,
} from '../../styles/ColorConstants';
import EmptyItem from './EmptyItem';
import ConferenceItem from './ConferenceItem';
import ConferenceHeader from './ConferenceHeader';

const dataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2,
	sectionHeaderHasChanged: (s1, s2) => s1 !== s2
});

const ConferenceListView = ({ style, scrollEnabled, rows, personal, disabled, conferenceData, saved, addConference, removeConference }) => {
	if (personal && Array.isArray(saved) && saved.length === 0) {
		return (
			<View style={[style, rows ? styles.card : styles.full]}>
				<Text style={styles.noSavedSessions}>
					Click the star icon next to a session to save it to your list.
				</Text>
			</View>
		);
	} else {
		return (
			<ListView
				style={[style, rows ? styles.card : styles.full]}
				scrollEnabled={scrollEnabled}
				stickySectionHeadersEnabled={false}
				dataSource={dataSource.cloneWithRowsAndSections(convertToTimeMap(conferenceData.schedule, adjustData(conferenceData.schedule, conferenceData.uids, saved, personal, rows)))}
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
};

function adjustData(scheduleIdMap, scheduleIdArray, savedArray, personal, rows) {
	// Filter out saved items
	if (!personal || !Array.isArray(savedArray)) {
		const keys = scheduleIdArray;
		if (!rows) {
			return scheduleIdArray;
		} else {
			const trimmed = [];

			for (let i = 0; i < rows; ++i) {
				trimmed.push(keys[i]);
			}
			return trimmed;
		}
	} else {
		let filtered = [];
		for (let i = 0; i < savedArray.length; ++i) {
			const key = savedArray[i];
			filtered.push(key);
		}

		// Displaying for homecard
		// Remove passed sessions
		if (rows) {
			const now = Date.now();
			if (filtered.length > rows) {
				const temp = filtered.slice();
				for (let j = 0; j < filtered.length; ++j) {
					const key = filtered[j];
					const itemTime = scheduleIdMap[key]['start-time'];

					if (now > itemTime) {
						const index = temp.indexOf(key);
						temp.splice(index, 1);
					}

					if (temp.length <= rows) {
						break;
					}
				}

				if (temp.length > rows) {
					filtered = temp.slice(0, rows);
				} else {
					filtered = temp;
				}
			}
		}
		return filtered;
	}
}

function isSaved(savedArray, id) {
	if (Array.isArray(savedArray)) {
		for ( let i = 0; i < savedArray.length; ++i) {
			if (savedArray[i] === id) {
				return true;
			}
		}
	} else {
		return false;
	}
}

function convertToTimeMap(scheduleMap, scheduleArray, header = false) {
	const timeMap = {};

	if (Array.isArray(scheduleArray)) {
		scheduleArray.forEach((key) => {
			const session = scheduleMap[key];
			if (!timeMap[session['start-time']]) {
				// Create an entry in the map for the timestamp if it hasn't yet been created
				timeMap[session['start-time']] = [];
			}
			timeMap[session['start-time']].push(session);
		});

		// Remove an item from section so spacing lines up
		if (header) {
			Object.keys(timeMap).forEach((key) => {
				timeMap[key].pop();
			});
		}
	}
	return timeMap;
}

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
	rowContainer: { flexDirection: 'row', height: 76 },
	full: { width: WINDOW_WIDTH, height: (WINDOW_HEIGHT - NAVIGATOR_HEIGHT - TAB_BAR_HEIGHT) },
	card: { width: MAX_CARD_WIDTH },
	noSavedSessions: { flexGrow: 1, fontSize: 18, textAlign: 'center', padding: 40, lineHeight: 30 },
});

export default ActualConferenceListView;
