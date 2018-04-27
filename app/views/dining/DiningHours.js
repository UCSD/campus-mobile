import React from 'react'
import {
	View,
	Text,
} from 'react-native'
import moment from 'moment'

import ColoredDot from '../common/ColoredDot'
import {
	COLOR_MGREEN,
	COLOR_MRED
} from '../../styles/ColorConstants'
import css from '../../styles/css'

const dining = require('../../util/dining')

const generateHourElements = (hoursArray, status, today) => {
	const elementsArray = []
	let activeDotColor

	if (status) {
		activeDotColor = status.isOpen ?
			COLOR_MGREEN : COLOR_MRED
	}

	// Push hours
	hoursArray.forEach((hours) => {
		const operatingHours = dining.parseHours(hours)
		const isAlwaysOpen = (hours === 'Open 24/7')
		let todaysStatusElement = null

		// Check if valid status
		if (status) {
			if (status.currentHours) {
				// Determines if the hours we are currently iterating through
				// match with the current status, right now
				const hoursAreCurrentHours = (
					(
						status.currentHours === 'Open 24/7'
						&& moment().format('dddd') === today
					)
					||
					(
						status.currentHours.openingHour
						&& status.currentHours.openingHour.format('dddd') === today
						&& status.currentHours.openingHour.isSame(operatingHours.openingHour)
						&& status.currentHours.closingHour.isSame(operatingHours.closingHour)
					)
				)
				if (hoursAreCurrentHours) {
					todaysStatusElement = (
						<View>
							<ColoredDot
								size={10}
								color={activeDotColor}
								style={css.dd_status_icon}
							/>
						</View>
					)
				}
			}
		} else {
			// Status is invalid, return null
			todaysStatusElement = null
		}

		let newHourElementHoursText
		if (isAlwaysOpen) {
			newHourElementHoursText = 'Open 24 Hours'
		}
		else if (
			operatingHours.openingHour.format('h:mm a') !== 'Invalid date'
			&& operatingHours.closingHour.format('h:mm a') !== 'Invalid date'
		) {
			let openingHourAmPm = 'a.m.'
			if (operatingHours.openingHour.format('a') === 'pm') {
				openingHourAmPm = 'p.m.'
			}
			let closingHourAmPm = 'a.m.'
			if (operatingHours.closingHour.format('a') === 'pm') {
				closingHourAmPm = 'p.m.'
			}
			newHourElementHoursText = operatingHours.openingHour.format('h:mm ')
				+ openingHourAmPm
				+ ' – '
				+ operatingHours.closingHour.format('h:mm ')
				+ closingHourAmPm
		} else {
			newHourElementHoursText = 'Unknown hours'
		}

		const newHourElement = (
			<View key={hours} style={css.dd_hours_text_container}>
				<Text style={css.dd_hours_text_hours}>
					{newHourElementHoursText}
				</Text>
				{todaysStatusElement}
			</View>
		)

		elementsArray.push(newHourElement)
	})

	return elementsArray
}

const generateHours = (allHours, status) => {
	const hoursRows = []
	Object.keys(allHours).forEach((day) => {
		const todaysHours = allHours[day]

		// If eatery is closed today
		if (!todaysHours) {
			const todaysTitle = moment(day, 'ddd').format('dddd')
			const newHourRow = (
				<View
					key={todaysTitle}
					style={css.dd_hours_row}
				>
					<Text style={css.dd_hours_text_title}>{`${todaysTitle}:`}</Text>
					<View>
						<View style={css.dd_hours_text_container}>
							<Text style={css.dd_hours_text_hours}>
								Closed
							</Text>
							{
								(moment().isSame(moment(day, 'ddd'), 'day')) ? (
									<View>
										<ColoredDot
											size={10}
											color={COLOR_MRED}
											style={css.dd_status_icon}
										/>
									</View>
								) : (null)
							}
						</View>
					</View>
				</View>
			)

			hoursRows.push(newHourRow)
		}

		// If hours are malformed, return 'Unknown hours'
		else if (typeof todaysHours !== 'string') {
			const newHourRow = (
				<View
					key={day}
					style={css.dd_hours_row}
				>
					<Text style={css.dd_hours_text_title}>Unknown day:</Text>
					<View>
						<Text style={css.dd_hours_text_hours}>Unknown hours</Text>
					</View>
				</View>
			)

			hoursRows.push(newHourRow)
		}
		else {
			const todaysHoursArray = todaysHours.split(',')
			const todaysTitle = moment(day, 'ddd').format('dddd')
			const todaysHoursElements = generateHourElements(todaysHoursArray, status, todaysTitle)

			const newHourRow = (
				<View
					key={todaysTitle}
					style={css.dd_hours_row}
				>
					<Text style={css.dd_hours_text_title}>{`${todaysTitle}:`}</Text>
					<View>
						{todaysHoursElements}
					</View>
				</View>
			)

			hoursRows.push(newHourRow)
		}
	})
	return hoursRows
}

const generateSpecialHours = (allHours, status) => {
	const hoursRows = []
	Object.keys(allHours).forEach((day) => {
		const todaysHours = allHours[day].hours
		let todaysTitle
		if (allHours[day].title) {
			todaysTitle = allHours[day].title
		} else {
			todaysTitle = 'Unknown'
		}

		// If hours are malformed, return 'Unknown hours'
		if (typeof todaysHours !== 'string') {
			const newHourRow = (
				<View
					key={day}
					style={css.dd_hours_row}
				>
					<Text style={css.dd_special_hours_text_title}>{`${todaysTitle}:`}</Text>
					<View>
						<Text style={css.dd_hours_text_hours}>Unknown hours</Text>
					</View>
				</View>
			)

			hoursRows.push(newHourRow)
		} else {
			const newHourRow = (
				<View
					key={day}
				>
					<Text style={css.dd_special_hours_text_title}>{`${todaysTitle}:`}</Text>
					<Text style={css.dd_hours_text_special_hours}>{todaysHours}</Text>
				</View>
			)

			hoursRows.push(newHourRow)
		}
	})
	return hoursRows
}

const DiningHours = ({
	hours,
	status,
	specialHours,
	style
}) => {
	let hoursElements
	if (specialHours) hoursElements = generateSpecialHours(hours, status)
	else hoursElements = generateHours(hours, status)
	return (
		<View>
			{
				(specialHours && hoursElements.length > 0) ? (
					<Text style={css.dd_description_subtext}>
						Special hours:
					</Text>
				) : null
			}
			<View style={[style]}>
				{hoursElements}
			</View>
		</View>
	)
}

export default DiningHours
