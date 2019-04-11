import React from 'react'
import { View, Text, FlatList } from 'react-native'
import { connect } from 'react-redux'
import moment from 'moment'
import Touchable from '../common/Touchable'
import SpecialEventsItem from './SpecialEventsItem'
import SpecialEventsHeader from './SpecialEventsHeader'
import css from '../../styles/css'

const SpecialEventsListView = ({
	navigation,
	addSpecialEvents,
	specialEventsSchedule,
	specialEventsScheduleIds,
	removeSpecialEvents,
	saved,
	disabled,
	personal,
	rows,
	scrollEnabled,
	style,
	labels,
	labelItemIds,
	selectedDay,
	days,
	daysItemIds,
	inCard,
	specialEventsTitle,
	handleFilterPress
}) => {
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
			<View style={[style, rows ? css.selv_card : css.selv_full]}>
				<Text style={css.selv_noSessions}>
					Click the star icon next to a session to save it to your schedule.
				</Text>
			</View>
		)
	} else {
		let lastStartTime

		return (
			<View style={css.selv_mainContainer}>
				<LabelsContainer
					labels={labels}
					hide={personal}
					handleFilterPress={handleFilterPress}
				/>
				{(!personal && scheduleIdArray.length === 0) ? (
					<Text style={css.selv_noSessions}>
						There are no events for your selected filters.
					</Text>
				) : (
					<FlatList
						style={[style, rows ? css.selv_card : css.selv_full]}
						scrollEnabled={scrollEnabled}
						stickySectionHeadersEnabled={false}
						data={getEvents(specialEventsSchedule,adjustData(specialEventsSchedule, scheduleIdArray, saved, personal, rows))}
						keyExtractor={item => item.id}
						renderItem={(item) => {
							const rowData = item.item
							const specialEventsHeader = (
								<SpecialEventsHeader
									timestamp={(lastStartTime !== rowData['start-time']) ? rowData['start-time'] : null}
									rows={rows}
								/>
							)
							lastStartTime = rowData['start-time']

							return (
								<View style={css.selv_rowContainer}>
									<View style={css.selv_rowContainer}>
										{specialEventsHeader}
										<SpecialEventsItem
											specialEventsData={rowData}
											saved={saved.includes(rowData.id)}
											add={(disabled) ? null : addSpecialEvents}
											remove={removeSpecialEvents}
											title={specialEventsTitle}
										/>
									</View>
								</View>
							)
						}}
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
			<Touchable
				onPress={() => handleFilterPress()}
				style={css.selv_labelsContainer}
			>
				<Text
					style={css.selv_labelText}
					numberOfLines={1}
				>
					<Text style={css.selv_labelHeader}>Filters: </Text>
					{
						labels.map((label, index) => label + ((index !== labels.length - 1) ? (', ') : ('')))
					}
				</Text>
			</Touchable>
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
	@return array of objects that corresponding to sheculeArray
*/
function getEvents(scheduleMap, scheduleArray, header = false) {
	const arrOfScheduleObj = []
	if (Array.isArray(scheduleArray)) {
		scheduleArray.forEach((key) => {
			const session = scheduleMap[key]
			arrOfScheduleObj.push(session)
		})
	}
	return arrOfScheduleObj
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

const ActualSpecialEventsListView = connect(mapStateToProps,mapDispatchToProps)(SpecialEventsListView)
export default ActualSpecialEventsListView
