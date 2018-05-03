import React from 'react'
import {
	View,
	Text,
	ListView,
	StyleSheet,
} from 'react-native'
import { connect } from 'react-redux'
import moment from 'moment'
import ElevatedView from 'react-native-elevated-view'

import COLOR from '../../styles/ColorConstants'
import LAYOUT from '../../styles/LayoutConstants'
import Touchable from '../common/Touchable'
import SpecialEventsItem from './SpecialEventsItem'
import SpecialEventsHeader from './SpecialEventsHeader'


const dataSource = new ListView.DataSource({
	rowHasChanged: (r1, r2) => r1 !== r2,
	sectionHeaderHasChanged: (s1, s2) => s1 !== s2
})

const SpecialEventsListView = ({ navigation, addSpecialEvents, specialEventsSchedule,
	specialEventsScheduleIds, removeSpecialEvents, saved,disabled, personal, rows,
	scrollEnabled, style, labels, labelItemIds, selectedDay, days, daysItemIds, inCard,
	specialEventsTitle, handleFilterPress }) => {

	let scheduleIdArray = []
	// Use ids from selectedDay
	if (daysItemIds) {
		if (!selectedDay) {
			// Select current day by default
			for (let i = 0; i < days.length; ++i) {
				selectedDay = days[i]
				if (moment(selectedDay).isSameOrAfter(moment(), 'day')) {
					scheduleIdArray = daysItemIds[selectedDay]

					// Filter saved for day
					if (personal && Array.isArray(saved)) {
						scheduleIdArray = scheduleIdArray.filter(item => saved.includes(item))
					}

					// If displaying for card...continue looking for a day with saved
					if (inCard && scheduleIdArray.length === 0) {
						// continue
					} else {
						break
					}
				}
			}
		}
		scheduleIdArray = daysItemIds[selectedDay]

		// Filter saved for day
		if (personal && Array.isArray(saved)) {
			scheduleIdArray = scheduleIdArray.filter(item => saved.includes(item))
		}

		// Apply label filtering
		if (!personal && labels.length > 0) {
			const labelSet = new Set() // Using set to get rid of dupes
			for (let j = 0; j < labels.length; ++j) {
				const label = labels[j]
				const items = labelItemIds[label]

				for (let k = 0; k < items.length; ++k) {
					labelSet.add(items[k])
				}
			}
			const labelArray = Array.from(labelSet)
			scheduleIdArray = scheduleIdArray.filter(item => labelArray.includes(item))
		}
	}
	if (personal && scheduleIdArray.length === 0) {
		return (
			<View style={[style, rows ? styles.card : styles.full]}>
				<Text style={styles.noSessions}>
					Click the star icon next to a session to save it to your schedule.
				</Text>
			</View>
		)
	} else {
		return (
			<View style={styles.mainContainer}>
				<LabelsContainer
					labels={labels}
					hide={personal}
					handleFilterPress={handleFilterPress}
				/>
				{(!personal && scheduleIdArray.length === 0) ? (
					<Text style={styles.noSessions}>
						There are no events for your selected filters.
					</Text>
				) : (
					<ListView
						style={[style, rows ? styles.card : styles.full]}
						scrollEnabled={scrollEnabled}
						stickySectionHeadersEnabled={false}
						dataSource={
							dataSource.cloneWithRowsAndSections(
								convertToTimeMap(
									specialEventsSchedule,
									adjustData(specialEventsSchedule, scheduleIdArray, saved, personal, rows)
								)
							)
						}
						renderRow={(rowData, sectionID, rowID, highlightRow) => {
							// Don't render first row bc rendered by header
							if (Number(rowID) !== 0) {
								return (
									<View style={styles.rowContainer}>
										<View style={styles.emptyRow} />
										<SpecialEventsItem
											specialEventsData={rowData}
											saved={saved.includes(rowData.id)}
											add={(disabled) ? null : addSpecialEvents}
											remove={removeSpecialEvents}
											title={specialEventsTitle}
										/>
									</View>
								)
							} else {
								return null
							}
						}}
						renderSectionHeader={(sectionData, sectionID) => (
							// Render header along with first row
							<View style={styles.rowContainer}>
								<SpecialEventsHeader
									timestamp={sectionID}
									rows={rows}
								/>
								<SpecialEventsItem
									specialEventsData={sectionData[0]}
									saved={saved.includes(sectionData[0].id)}
									add={(disabled) ? null : addSpecialEvents}
									remove={removeSpecialEvents}
									title={specialEventsTitle}
								/>
							</View>
						)}
					/>
				)}
			</View>
		)
	}
}

const LabelsContainer = ({ labels, hide, handleFilterPress }) => {
	if (hide || !Array.isArray(labels) || labels.length === 0) {
		return null
	} else {
		return (
			<ElevatedView
				elevation={2}
			>
				<Touchable
					onPress={() => handleFilterPress()}
					style={styles.labelsContainer}
				>
					<Text
						style={styles.labelText}
						numberOfLines={1}
					>
						<Text style={styles.labelHeader}>Filters: </Text>
						{
							labels.map((label, index) => label + ((index !== labels.length - 1) ? (', ') : ('')))
						}
					</Text>
				</Touchable>
			</ElevatedView>
		)
	}
}

/*
	Filters what session ids to use based on personal/saved and/or rows
	@returns Array of session ids
 */
function adjustData(scheduleIdMap, scheduleIdArray, savedArray, personal, rows) {
	// Filter out saved items
	if (!personal || !Array.isArray(savedArray)) {
		const keys = scheduleIdArray
		if (!rows) {
			return scheduleIdArray
		} else {
			const trimmed = []

			for (let i = 0; i < rows; ++i) {
				trimmed.push(keys[i])
			}
			return trimmed
		}
	} else {
		let filtered = []
		// Check if saved item is part of ids to be displayed
		for (let i = 0; i < savedArray.length; ++i) {
			const key = savedArray[i]
			if (scheduleIdArray.includes(key)) {
				filtered.push(key)
			}
		}

		// Displaying for homecard
		// Remove sessions that have passed
		if (rows) {
			const now = Date.now()
			if (filtered.length > rows) {
				const temp = filtered.slice()
				for (let j = 0; j < filtered.length; ++j) {
					const key = filtered[j]
					const itemTime = scheduleIdMap[key]['start-time']

					if (now > itemTime) {
						const index = temp.indexOf(key)
						temp.splice(index, 1)
					}

					if (temp.length <= rows) {
						break
					}
				}

				if (temp.length > rows) {
					filtered = temp.slice(0, rows)
				} else {
					filtered = temp
				}
			}
		}
		return filtered
	}
}

/*
	@returns Object that maps keys from scheduleArray to Objects in scheduleMap
*/
function convertToTimeMap(scheduleMap, scheduleArray, header = false) {
	const timeMap = {}

	if (Array.isArray(scheduleArray)) {
		scheduleArray.forEach((key) => {
			const session = scheduleMap[key]
			if (!timeMap[session['start-time']]) {
				// Create an entry in the map for the timestamp if it hasn't yet been created
				timeMap[session['start-time']] = []
			}
			timeMap[session['start-time']].push(session)
		})

		// Remove an item from section so spacing lines up
		if (header) {
			Object.keys(timeMap).forEach((key) => {
				timeMap[key].pop()
			})
		}
	}
	return timeMap
}

const mapStateToProps = state => ({
	specialEventsSchedule: state.specialEvents.data.schedule,
	specialEventsScheduleIds: state.specialEvents.data.uids,
	saved: state.specialEvents.saved,
	labelItemIds: state.specialEvents.data['label-items'],
	labels: state.specialEvents.labels,
	days: state.specialEvents.data.dates,
	daysItemIds: state.specialEvents.data['date-items'],
	specialEventsTitle: (state.specialEvents.data) ? state.specialEvents.data.name : '',
})

const mapDispatchToProps = dispatch => ({
	addSpecialEvents: (id) => {
		dispatch({ type: 'ADD_SPECIAL_EVENTS', id })
	},
	removeSpecialEvents: (id) => {
		dispatch({ type: 'REMOVE_SPECIAL_EVENTS', id })
	}
})

const ActualSpecialEventsListView = connect(
	mapStateToProps,
	mapDispatchToProps
)(SpecialEventsListView)

const styles = StyleSheet.create({
	mainContainer: { flexGrow: 1 },
	rowContainer: { flexDirection: 'row' },
	full: { flexGrow: 1, width: LAYOUT.WINDOW_WIDTH, height: (LAYOUT.WINDOW_HEIGHT - LAYOUT.NAVIGATOR_HEIGHT - LAYOUT.TAB_BAR_HEIGHT) },
	card: { width: LAYOUT.MAX_CARD_WIDTH },
	noSessions: { flexGrow: 1, fontSize: 16, textAlign: 'center', padding: 20, lineHeight: 22 },
	labelsContainer: { alignItems: 'center', justifyContent: 'flex-start', borderBottomWidth: 1, borderBottomColor: COLOR.PRIMARY },
	labelHeader: { fontWeight: '600', },
	labelText: { width: LAYOUT.WINDOW_WIDTH, paddingVertical: 4, paddingHorizontal: 20, fontSize: 14, color: COLOR.PRIMARY },
	emptyRow: { width: 75, flexDirection: 'row' },
})

export default ActualSpecialEventsListView